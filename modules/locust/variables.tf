variable "dns_name" {
    description = "The DNS name of the load balancer"
    type        = string
}

variable "vpc_security_group_ids" {
    description = "The security group ID(s) of the EC2 instance"
    type        = list(string)
}

variable "subnet_id" {
    description = "The subnet ID of the EC2 instance"
    type        = string
}