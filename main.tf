terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~>3.6.0"
        }
    }

    required_version = ">= 1.0.0"
}

provider "aws" {
    region = "us-east-1"
}

module "vpc" {
    source = "./vpc"
}

module "sg" {
    source = "./sg"
    vpc_id = module.vpc.vpc_id
}

module "iam" {
    source = "./iam"
}


resource "aws_lb_target_group" "target_group" {
    health_check {
        interval = 10
        path = "/"
        protocol = "HTTP"
        timeout = 5
        healthy_threshold = 5
        unhealthy_threshold = 2
    }  

    name = "cloud-target-group"
    port = 80
    protocol = "HTTP"
    target_type = "instance"
    vpc_id = module.vpc.vpc_id
}

resource "aws_lb" "application_lb" {
    name = "cloud-application-lb"
    internal = false
    ip_address_type = "ipv4"
    load_balancer_type = "application"
    security_groups = [module.sg.lb_sg_id]
    subnets = [module.vpc.cloud_public_subnet_id, module.vpc.cloud_public_subnet2_id]

    tags = {
        name = "cloud_application_lb"
    }
}

resource "aws_lb_listener" "listener" {
    load_balancer_arn = aws_lb.application_lb.arn
    port = 80
    protocol = "HTTP"

    default_action {
        target_group_arn = aws_lb_target_group.target_group.arn
        type = "forward"
    }
}

resource "aws_launch_template" "gym_template" {
    name = "backend_template"
    image_id = "ami-0d86d19bb909a6c95"
    instance_type = "t2.micro"
    key_name = "cloud_key"
    vpc_security_group_ids = [module.sg.ec2_sg_id]

    user_data = base64encode(var.user_data)

    tag_specifications {
        resource_type = "instance"
        tags = {
            Name = "cloud_instance"
        }
    }

    iam_instance_profile {
        name = module.iam.iam_profile_name
    }
}

resource "aws_autoscaling_group" "asg" {
    desired_capacity = 1
    max_size = 5
    min_size = 1
    availability_zones = [ "us-east-1a", "us-east-1b"  ]
    health_check_grace_period = 300
    health_check_type = "EC2"

    launch_template {
        id = aws_launch_template.gym_template.id
        version = "$Latest"
    }

    target_group_arns = [aws_lb_target_group.target_group.arn]
}

resource "aws_cloudwatch_metric_alarm" "asg_metric_alarm_up" {
    alarm_name = "asg_metric_alarm_up"
    comparison_operator = "GreaterThanOrEqualToThreshold"
    evaluation_periods = "2"
    metric_name = "CPUUtilization"
    namespace = "AWS/EC2"
    period = "120"
    statistic = "Average"
    threshold = "70"
    alarm_description = "This metric monitors ec2 cpu utilization"
    alarm_actions = [aws_autoscaling_policy.asg_policy_up.arn]
    dimensions = {
        AutoScalingGroupName = aws_autoscaling_group.asg.name
    }
}

resource "aws_autoscaling_policy" "asg_policy_up" {
    name = "EC2 Autoscaling Up"
    autoscaling_group_name = aws_autoscaling_group.asg.name
    scaling_adjustment = 1
    adjustment_type = "ChangeInCapacity"
    cooldown = 300
}

resource "aws_cloudwatch_metric_alarm" "asg_metric_alarm_down" {
    alarm_name = "asg_metric_alarm_down"
    comparison_operator = "LessThanOrEqualToThreshold"
    evaluation_periods = "2"
    metric_name = "CPUUtilization"
    namespace = "AWS/EC2"
    period = "120"
    statistic = "Average"
    threshold = "30"
    alarm_description = "This metric monitors ec2 cpu utilization"
    alarm_actions = [aws_autoscaling_policy.asg_policy_down.arn]
    dimensions = {
        AutoScalingGroupName = aws_autoscaling_group.asg.name
    }
}

resource "aws_autoscaling_policy" "asg_policy_down" {
    name = "EC2 Autoscaling Down"
    autoscaling_group_name = aws_autoscaling_group.asg.name
    scaling_adjustment = -1
    adjustment_type = "ChangeInCapacity"
    cooldown = 300
}


# resource "aws_instance" "cloud_1_instance" {
#     instance_type = "t2.micro"
#     ami = "ami-06aa3f7caf3a30282"
#     key_name = "cloud_key"

#     subnet_id = module.vpc.cloud_public_subnet_id
#     vpc_security_group_ids = [module.sg.ec2_sg_id]
#     associate_public_ip_address = true

#     user_data = <<-EOF
#         #!/bin/bash
#         sudo apt-get update
#         sudo apt-get install -y nginx
#         sudo systemctl enable nginx
#         sudo systemctl start nginx
#     EOF

#     tags = {
#         name = "cloud_1_instance"
#     }
# }