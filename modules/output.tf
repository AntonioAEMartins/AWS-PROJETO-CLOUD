output "load_balancer_dns_name" {
    value = "${module.alb.load_balancer_dns_name}/docs"
}

output "locust_dns_name" {
    value = "${module.locust.locust_endpoint}:8089"
}