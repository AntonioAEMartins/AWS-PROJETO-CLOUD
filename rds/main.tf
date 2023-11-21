module "sg" {
    source = "../sg"
    vpc_id = module.vpc.vpc_id
}

resource "aws_db_subnet_group" "db_subnet" {
    name = "db_subnet"
    subnet_ids = [module.vpc.cloud_private_subnet_subnet_id, module.vpc.cloud_private_subnet2]

    tags = {
        Name = "db_subnet"
    }
}

resource "aws_db_instance" "rds_instance" {
    engine = "mysql"
    engine_version = "8.0.31"
    multi_az = true ## MUDAR ISSO
    identifier = "gym-rds-instance"
    username = "antonioaem" ##MUDAR
    password = "teste" ##MUDAR
    instance_class = "db.t2.micro"
    allocated_storage = 20
    db_subnet_group_name = aws_db_subnet_group.db_subnet.name
    vpc_security_group_ids = [module.sg.rds_sg_id]

    backup_retention_period = 7
    backup_window = "00:00-00:30"
    maintenance_window = "Mon:00:00-Mon:03:00"
    
    publicly_accessible = false
    skip_final_snapshot = true

    tags = {
        Name = "gym-rds-instance"
    }
}