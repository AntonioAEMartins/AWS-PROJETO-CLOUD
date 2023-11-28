terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~> 4.0.0"
        }
    }

    required_version = ">= 1.6.0"

    backend "s3" {
        bucket = "cloud-2023-terraform-state"
        key = "terraform.tfstate"
        region = "us-east-1"
    }
}

provider "aws" {
    region = "us-east-1"
}

module "vpc" {
    source = "./vpc"
}

module "alb" {
    source = "./alb"
    vpc_id = module.vpc.vpc_id
    cloud_public_subnet_id = module.vpc.cloud_public_subnet_id
    cloud_public_subnet2_id = module.vpc.cloud_public_subnet2_id
    lb_sg_id = module.sg.lb_sg_id
}

module "sg" {
    source = "./sg"
    vpc_id = module.vpc.vpc_id
}

module "iam" {
    source = "./iam"
}

module "rds" {
    source = "./rds"
    vpc_id = module.vpc.vpc_id
    cloud_private_subnet_subnet_id = module.vpc.cloud_private_subnet_subnet_id
    cloud_private_subnet2_subnet_id = module.vpc.cloud_private_subnet2_subnet_id
    rds_sg_id = module.sg.rds_sg_id
}

resource "aws_launch_template" "gym_template" {
    name = "backend_template"
    image_id = "ami-0fc5d935ebf8bc3bc"
    instance_type = "t2.micro"
    key_name = "cloud_key"
    vpc_security_group_ids = [module.sg.ec2_sg_id]

    user_data = base64encode(templatefile("teste.tftpl",{
        db_host = module.rds.db_host,
        db_name = module.rds.db_name,
        db_user = module.rds.db_username,
        db_pass = module.rds.db_password
    }))

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
    desired_capacity = 2
    max_size = 5
    min_size = 1
    vpc_zone_identifier = [module.vpc.cloud_public_subnet_id, module.vpc.cloud_public_subnet2_id]
    health_check_grace_period = 300
    health_check_type = "EC2"

    launch_template {
        id = aws_launch_template.gym_template.id
        version = "$Latest"
    }

    target_group_arns = [module.alb.target_group_arn]
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