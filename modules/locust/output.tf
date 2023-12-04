output "locust_endpoint" {
    value = aws_instance.cloud_ec2_locust.public_ip
}