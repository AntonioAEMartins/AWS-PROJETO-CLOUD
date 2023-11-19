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
    vpc_id = module.vpc.cloud_vpc_id
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

    name = "cloud_target_group"
    port = 80
    protocol = "HTTP"
    target_type = "instance"
    vpc_id = module.vpc.cloud_vpc_id
}

resource "aws_lb" "application_lb" {
    name = "cloud_application_lb"
    internal = false
    ip_address_type = "ipv4"
    load_balancer_type = "application"
    security_groups = [module.sg.cloud_lb_sg_id]
    subnets = [module.vpc.cloud_public_subnet_id]

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

resource "aws_lb_target_group_attachment" "cloud_1_instance_attachment" {
    count = length(aws_instance.cloud_1_instance)
    target_group_arn = aws_lb_target_group.target_group.arn
    target_id = aws_instance.cloud_1_instance[count.index].id
}

resource "aws_instance" "cloud_1_instance" {
    instance_type = "t2.micro"
    ami = "ami-06aa3f7caf3a30282"
    key_name = "cloud_key"

    subnet_id = module.vpc.cloud_public_subnet_id
    vpc_security_group_ids = [module.sg.cloud_ec2_sg_id]
    associate_public_ip_address = true

    user_data = <<-EOF
        #!/bin/bash
        sudo apt-get update
        sudo apt-get install -y nginx
        sudo systemctl enable nginx
        sudo systemctl start nginx
    EOF

    tags = {
        name = "cloud_1_instance"
    }
}