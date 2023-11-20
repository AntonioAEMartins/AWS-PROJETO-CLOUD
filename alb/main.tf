module "vpc" {
    source = "../vpc"
}

module "sg" {
    source = "../sg"
    vpc_id = module.vpc.vpc_id
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