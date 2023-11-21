resource "aws_lb_target_group" "target_group" {
  health_check {
    interval           = 10
    path               = "/"
    protocol           = "HTTP"
    timeout            = var.target_group_timeout
    healthy_threshold  = var.target_group_health_threshold
    unhealthy_threshold = var.target_group_unhealthy_threshold
  }

  name        = var.lb_target_group_name
  port        = var.lb_listener_port
  protocol    = "HTTP"
  target_type = var.target_group_instance_type
  vpc_id      = var.vpc_id
}

resource "aws_lb" "application_lb" {
  name               = var.lb_name
  internal           = false
  ip_address_type    = "ipv4"
  load_balancer_type = "application"
  security_groups    = [var.lb_sg_id]
  subnets            = [var.cloud_public_subnet_id, var.cloud_public_subnet2_id]

  tags = var.lb_tags
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.application_lb.arn
  port              = var.lb_listener_port
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.target_group.arn
    type             = "forward"
  }
}
