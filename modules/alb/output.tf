output "target_group_arn" {
    value = aws_lb_target_group.target_group.arn
}

output "load_balancer_dns_name" {
    value = aws_lb.application_lb.dns_name
}