resource "aws_subnet" "back_subnet_eu_west_3c" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "192.168.11.0/24"
  availability_zone = "eu-west-3c"

  tags = {
    Name = "soar_back_subnet_eu_west_3c"
  }

  depends_on = [aws_internet_gateway.igw]
}

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
sleep 30 # wait for yum to be ready
mkdir -p /app
cd /app
touch start
sudo yum update -y 1>>server_logs.txt 2>&1
touch updated
sudo yum install -y git 1>>server_logs.txt 2>&1
touch git
curl --silent --location https://rpm.nodesource.com/setup_12.x | sudo bash - && sudo yum -y install nodejs 1>>server_logs.txt 2>&1
touch npm
git clone https://${var.gittoken}@github.com/gwaihirSIGL/soar-platform-2-back.git 1>>server_logs.txt 2>&1
cd soar-platform-2-back/
echo "PGHOST='${aws_eip.database_lb.public_dns}'
POSTGRES_USER='${var.database_user}'
POSTGRES_PASSWORD='${var.database_password}'
POSTGRES_DB=soar
POSTGRES_PORT=3306
PORT=4002
" > .env
sudo npm i 1>>server_logs.txt 2>&1
sudo npm start 1>>server_logs.txt 2>&1
EOF

}

resource "aws_autoscaling_group" "back_asg" {
  name = "${aws_launch_configuration.back_instance_template.name}-auto-scaling-group"

  min_size             = 1
  desired_capacity     = 1
  max_size             = 3
  
  health_check_type    = "ELB"
  load_balancers = [
    aws_elb.back_load_balancer.id,
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

# Load Balancer operating at OSI 4th layer
resource "aws_elb" "back_load_balancer" {
  name = "back-load-balancer"

  security_groups = [
    aws_security_group.allow_every_outbound_traffic.id,
    aws_security_group.allow_http.id,
  ]

  subnets = [
    aws_subnet.back_subnet_eu_west_3c.id,
  ]

  cross_zone_load_balancing   = true

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 5
    timeout = 59
    interval = 60
    target = "HTTP:80/"
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
  evaluation_periods = 2
  metric_name = "CPUUtilization"
  namespace = "AWS/EC2"
  period = 120
  statistic = "Average"
  threshold = 60

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.back_asg.name
  }

  alarm_description = "EC2 CPU utilization increased : scaling up .."
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
  evaluation_periods = 2
  metric_name = "CPUUtilization"
  namespace = "AWS/EC2"
  period = 120
  statistic = "Average"
  threshold = 10

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.back_asg.name
  }

  alarm_description = "EC2 CPU utilization decreased : scaling down .."
  alarm_actions = [
    aws_autoscaling_policy.back_policy_scale_down.arn,
  ]
}

resource "aws_route_table_association" "route_to_igw" {
  subnet_id      = aws_subnet.back_subnet_eu_west_3c.id
  route_table_id = aws_route_table.route_to_igw.id
}

# module "back_nat_gateway" {
#   source = "./modules/nat_gateway"

#   vpc_id = aws_vpc.main.id
#   internet_gateway_id = aws_internet_gateway.igw.id
#   nat_gateway_subnet_cidr = "192.168.14.0/24"
#   nat_gateway_az = "eu-west-3c"
#   instances_to_root_subnet_id = aws_subnet.back_subnet_eu_west_3c.id
# }

# module "bastion_to_back_instances" {
#   source = "./modules/simple_host"

#   subnet_id = module.back_nat_gateway.nat_gateway_subnet_id
#   key_name = aws_key_pair.main.key_name
#   vpc_security_group_ids = [
#     aws_security_group.allow_ssh.id,
#     aws_security_group.allow_every_outbound_traffic.id,
#   ]
# }

# output "back_bastion_ip" {
#   value = module.bastion_to_back_instances.instance_ip
# }
