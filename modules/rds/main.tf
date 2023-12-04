resource "aws_db_subnet_group" "db_subnet" {
    name = "db_subnet"
    subnet_ids = [var.cloud_private_subnet_subnet_id, var.cloud_private_subnet2_subnet_id]

    tags = {
        Name = "db_subnet"
    }
}

resource "aws_db_instance" "rds_instance" {
    engine = "mysql"
    engine_version = "8.0.31"

    identifier = "rds-instance"

    db_name = "rds"
    username = "antonio"
    password = "teste123"

    instance_class = "db.t2.micro"
    allocated_storage = 20
    storage_type = "gp2"

    db_subnet_group_name = aws_db_subnet_group.db_subnet.name
    vpc_security_group_ids = [var.rds_sg_id]

    backup_retention_period = 7
    backup_window         = "00:30-01:00"
    maintenance_window    = "Mon:01:00-Mon:03:00"

    publicly_accessible = false
    skip_final_snapshot = true
    multi_az = true
    # multi_az = false

    tags = {
        Name = "gym-rds-instance"
    }
}