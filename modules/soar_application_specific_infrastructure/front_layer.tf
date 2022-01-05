resource "aws_launch_configuration" "front_instance_template" {
  image_id      = "ami-013e3966f8522cff2"
  instance_type = "t2.micro"

  name_prefix = "front-instance-"

  key_name = var.ssh_pub_key_file_name

  security_groups = [
    var.allow_ingress_mysql_from_vpc_id,
    var.allow_outbound_sec_group_id,
    var.allow_ssh_sec_group_id,
  ]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "front_asg" {
  name = "${aws_launch_configuration.front_instance_template.name}-auto-scaling-group"

  min_size             = 1
  desired_capacity     = 1
  max_size             = 3
  
  health_check_type    = "ELB"
  load_balancers = [
    var.front_lb_id,
  ]

  launch_configuration = aws_launch_configuration.front_instance_template.name

  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupTotalInstances",
  ]

  metrics_granularity = "1Minute"

  vpc_zone_identifier  = [
    var.front_subnet_id,
  ]

  lifecycle {
    create_before_destroy = true
  }

  tag {
    key                 = "Name"
    value               = "front-instance"
    propagate_at_launch = true
  }

}

resource "aws_autoscaling_policy" "front_policy_scale_up" {
  name = "front_policy_scale_up"
  scaling_adjustment = 1
  adjustment_type = "ChangeInCapacity"
  cooldown = 60
  autoscaling_group_name = aws_autoscaling_group.front_asg.name
}

resource "aws_cloudwatch_metric_alarm" "front_instance_cpu_alarm_scale_up" {
  alarm_name = "front_instance_cpu_alarm_scale_up"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods = 2
  metric_name = "CPUUtilization"
  namespace = "AWS/EC2"
  period = 120
  statistic = "Average"
  threshold = 60

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.front_asg.name
  }

  alarm_description = "EC2 CPU utilization increased : scaling up .."
  alarm_actions = [
    aws_autoscaling_policy.front_policy_scale_up.arn,
  ]
}

resource "aws_autoscaling_policy" "front_policy_scale_down" {
  name = "front_policy_scale_down"
  scaling_adjustment = -1
  adjustment_type = "ChangeInCapacity"
  cooldown = 60
  autoscaling_group_name = aws_autoscaling_group.front_asg.name
}

resource "aws_cloudwatch_metric_alarm" "front_instance_cpu_alarm_scale_down" {
  alarm_name = "front_instance_cpu_alarm_scale_down"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods = 2
  metric_name = "CPUUtilization"
  namespace = "AWS/EC2"
  period = 120
  statistic = "Average"
  threshold = 10

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.front_asg.name
  }

  alarm_description = "EC2 CPU utilization decreased : scaling down .."
  alarm_actions = [
    aws_autoscaling_policy.front_policy_scale_down.arn,
  ]
}

module "front_nat_gateway" {
  source = "../nat_gateway"

  vpc_id = var.vpc_id
  internet_gateway_id = var.internet_gateway_id
  nat_gateway_subnet_cidr = "192.168.14.0/24"
  nat_gateway_az = "eu-west-3c"
}

module "bastion_to_front_instances" {
  source = "../simple_host"

  subnet_id = var.front_subnet_id
  key_name = var.ssh_pub_key_file_name
  vpc_security_group_ids = [
    var.allow_ssh_sec_group_id,
    var.allow_outbound_sec_group_id,
  ]
}

output "front_bastion_ip" {
  value = module.bastion_to_front_instances.instance_ip
}
