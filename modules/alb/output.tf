output "target_group_arn" {
    value = aws_lb_target_group.target_group.arn
}

output "load_balancer_dns_name" {
    value = aws_lb.application_lb.dns_name
}

output "load_balancer_id" {
    value = aws_lb.application_lb.id
}

output "load_balancer_name"{
    value = aws_lb.application_lb.name
}