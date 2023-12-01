resource "aws_instance" "cloud_ec2_locust" {
    ami = "ami-0fc5d935ebf8bc3bc"
    instance_type = "t2.micro"
    vpc_security_group_ids = var.vpc_security_group_ids
    subnet_id = var.subnet_id
    
    associate_public_ip_address = true

    user_data = base64encode(templatefile("locus_data.tftpl", {
        dns_name = var.dns_name,
    }))

    tags = {
        Name = "cloud_ec2_locust"
    }
}