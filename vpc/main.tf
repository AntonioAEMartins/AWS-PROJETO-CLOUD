resource "aws_vpc" "cloud_vpc" {
    cidr_block = "10.0.0.0/16"
    tags = {
        name = "cloud_vpc"
    }
}

resource "aws_subnet" "cloud_public_subnet" {
    vpc_id = aws_vpc.cloud_vpc.id
    cidr_block = "10.0.1.0/24"
    availability_zone = "us-east-1a"

    tags = {
        name = "cloud_subnet"
    }
}

resource "aws_subnet" "cloud_private_subnet" {
    vpc_id = aws_vpc.cloud_vpc.id
    cidr_block = "10.0.2.0/24"
    availability_zone = "us-east-1a"

    tags = {
        name = "cloud_subnet"
    }
}

resource "aws_internet_gateway" "cloud_ig" {
    vpc_id = aws_vpc.cloud_vpc.id

    tags = {
        name = "cloud_ig"
    }
}

resource "aws_route_table" "cloud_public_rt" {
    vpc_id = aws_vpc.cloud_vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.cloud_ig.id
    }

    route {
        ipv6_cidr_block        = "::/0"
        gateway_id             = aws_internet_gateway.cloud_ig.id
    }

    tags = {
        name = "cloud_public_rt"
    }
}

resource "aws_route_table_association" "cloud_public_subnet_rt_association" {
    subnet_id = aws_subnet.cloud_public_subnet.id
    route_table_id = aws_route_table.cloud_public_rt.id
}