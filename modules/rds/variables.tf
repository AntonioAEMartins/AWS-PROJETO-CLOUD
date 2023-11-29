variable "vpc_id" {
    description = "VPC ID"
    type = string
}

variable "cloud_private_subnet_subnet_id" {
    description = "Private Subnet ID"
    type = string
}

variable "cloud_private_subnet2_subnet_id" {
    description = "Private Subnet ID"
    type = string
}

variable "rds_sg_id" {
    description = "RDS Security Group ID"
    type = string
}