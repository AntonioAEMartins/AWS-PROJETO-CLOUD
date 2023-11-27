output "cloud_public_subnet_id" {
    value = aws_subnet.cloud_public_subnet.id  
}

output "cloud_public_subnet2_id" {
    value = aws_subnet.cloud_public_subnet2.id  
}

output "vpc_id" {
    value = aws_vpc.cloud_vpc.id
}

output "cloud_private_subnet_subnet_id" {
    value = aws_subnet.cloud_private_subnet.id
}

output "cloud_private_subnet2_subnet_id" {
    value = aws_subnet.cloud_private_subnet2.id
}
