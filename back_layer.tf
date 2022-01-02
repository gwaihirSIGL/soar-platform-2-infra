resource "aws_subnet" "back_subnet_eu_west_3b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "192.168.1.0/24"
  availability_zone = "eu-west-3b"

  tags = {
    Name = "soar_back_subnet_eu_west_3b"
  }

  depends_on = [aws_internet_gateway.igw]
}

resource "aws_subnet" "back_subnet_eu_west_3c" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "192.168.1.0/24"
  availability_zone = "eu-west-3c"

  tags = {
    Name = "soar_back_subnet_eu_west_3c"
  }

  depends_on = [aws_internet_gateway.igw]
}

resource "aws_route_table_association" "igw_route_to_back_eu_west_3b" {
  subnet_id      = aws_subnet.back_subnet_eu_west_3b.id
  route_table_id = aws_route_table.main.id
}

resource "aws_route_table_association" "igw_route_to_back_eu_west_3c" {
  subnet_id      = aws_subnet.back_subnet_eu_west_3c.id
  route_table_id = aws_route_table.main.id
}

# resource "aws_instance" "back_instance" {
#   ami           = "ami-0d3c032f5934e1b41"
#   instance_type = "t2.micro"
#   subnet_id     = aws_subnet.back.id
#   private_ip    = "192.168.1.50"

#   security_groups = [
#     aws_security_group.allow_ssh.id,
#     aws_security_group.allow_every_outbound_traffic.id,
#     aws_security_group.allow_http.id,
#   ]

#   key_name = aws_key_pair.main.key_name

#   depends_on = [aws_eip.database_lb]

#   tags = {
#     Name = "soar_back_instance"
#   }

#   user_data = <<EOF
# #!/bin/bash
# sudo yum update -y
# sudo yum install -y git
# curl --silent --location https://rpm.nodesource.com/setup_12.x | sudo bash - && sudo yum -y install nodejs
# mkdir /app
# cd /app
# git clone https://${var.gittoken}@github.com/gwaihirSIGL/soar-platform-2-back.git
# cd soar-platform-2-back/
# echo "PGHOST='${aws_eip.database_lb.public_dns}'
# POSTGRES_USER='${var.database_user}'
# POSTGRES_PASSWORD='${var.database_password}'
# POSTGRES_DB=soar
# POSTGRES_PORT=3306
# PORT=4002
# " > .env
# sudo npm i
# sudo npm start 1>server_logs.txt 2>&1 &
# EOF
# }

# resource "aws_eip" "back_lb" {
#   instance   = aws_instance.back_instance.id
#   vpc        = true
#   depends_on = [aws_internet_gateway.igw]
# }

resource "aws_launch_configuration" "back_instance_template" {
  image_id      = "ami-0d3c032f5934e1b41"
  instance_type = "t2.micro"

  name_prefix = "back-instance-"

  key_name = aws_key_pair.main.key_name

  security_groups = [
    aws_security_group.allow_ssh.id,
    aws_security_group.allow_every_outbound_traffic.id,
    aws_security_group.allow_http.id,
  ]

  lifecycle {
    create_before_destroy = true
  }

  user_data = <<EOF
#!/bin/bash
sudo yum update -y
sudo yum install -y git
curl --silent --location https://rpm.nodesource.com/setup_12.x | sudo bash - && sudo yum -y install nodejs
mkdir /app
cd /app
git clone https://${var.gittoken}@github.com/gwaihirSIGL/soar-platform-2-back.git
cd soar-platform-2-back/
echo "PGHOST='${aws_eip.database_lb.public_dns}'
POSTGRES_USER='${var.database_user}'
POSTGRES_PASSWORD='${var.database_password}'
POSTGRES_DB=soar
POSTGRES_PORT=3306
PORT=4002
" > .env
sudo npm i
sudo npm start 1>server_logs.txt 2>&1 &
EOF

}

resource "aws_autoscaling_group" "back_asg" {
  name = "${aws_launch_configuration.back_instance_template.name}-auto-scaling-group"

  min_size             = 1
  desired_capacity     = 1
  max_size             = 3
  
  health_check_type    = "ELB"
  load_balancers = [
    aws_elb.back_load_balancer.id
  ]

  launch_configuration = aws_launch_configuration.back_instance_template.name

  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupTotalInstances",
  ]

  metrics_granularity = "1Minute"

  vpc_zone_identifier  = [
    aws_subnet.back_subnet_eu_west_3b.id,
    aws_subnet.back_subnet_eu_west_3c.id,
  ]

  lifecycle {
    create_before_destroy = true
  }

  tag {
    key                 = "Name"
    value               = "back-instance"
    propagate_at_launch = true
  }

}

resource "aws_elb" "back_load_balancer" {
  name = "back-elb"

  security_groups = [
    aws_security_group.allow_every_outbound_traffic.id,
    aws_security_group.allow_http.id,
  ]

  subnets = [
    aws_subnet.back_subnet_eu_west_3b.id,
    aws_subnet.back_subnet_eu_west_3c.id,
  ]

  cross_zone_load_balancing   = true

  health_check {
    healthy_threshold = 3
    unhealthy_threshold = 3
    timeout = 3
    interval = 10
    target = "HTTP:80/"   # FIXME
  }

  listener {
    lb_port = 80
    lb_protocol = "http"
    instance_port = 80
    instance_protocol = "http"
  }
}

resource "aws_autoscaling_policy" "back_policy_scale_up" {
  name = "back_policy_scale_up"
  scaling_adjustment = 1
  adjustment_type = "ChangeInCapacity"
  cooldown = 60
  autoscaling_group_name = aws_autoscaling_group.back_asg.name
}

resource "aws_cloudwatch_metric_alarm" "back_instance_cpu_alarm_scale_up" {
  alarm_name = "back_instance_cpu_alarm_scale_up"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods = "2"
  metric_name = "CPUUtilization"
  namespace = "AWS/EC2"
  period = "120"
  statistic = "Average"
  threshold = "60"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.back_asg.name
  }

  alarm_description = "Monitor EC2 instance CPU utilization (increase)"
  alarm_actions = [
    aws_autoscaling_policy.back_policy_scale_up.arn,
  ]
}

resource "aws_autoscaling_policy" "back_policy_scale_down" {
  name = "back_policy_scale_down"
  scaling_adjustment = -1
  adjustment_type = "ChangeInCapacity"
  cooldown = 60
  autoscaling_group_name = aws_autoscaling_group.back_asg.name
}

resource "aws_cloudwatch_metric_alarm" "back_instance_cpu_alarm_scale_down" {
  alarm_name = "back_instance_cpu_alarm_scale_down"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods = "2"
  metric_name = "CPUUtilization"
  namespace = "AWS/EC2"
  period = "120"
  statistic = "Average"
  threshold = "10"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.back_asg.name
  }

  alarm_description = "Monitor EC2 instance CPU utilization (decrease)"
  alarm_actions = [
    aws_autoscaling_policy.back_instance_cpu_alarm_scale_down.arn,
  ]
}
