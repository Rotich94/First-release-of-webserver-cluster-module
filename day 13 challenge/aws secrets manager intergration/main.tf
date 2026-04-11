resource "aws_secretsmanager_secret" "example" {
  name = "example-secret"
}

resource "aws_secretsmanager_secret_version" "example" {
  secret_id = aws_secretsmanager_secret.example.id
  secret_string = jsonencode({
    username = "admin"
    password = "MySecurePassword123!"
  })
}

locals {
  example = jsondecode(
    aws_secretsmanager_secret_version.example.secret_string
  )
}

# VPC
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "rds-vpc"
  }
}

# Subnets for RDS (requires at least 2 in different AZs)
resource "aws_subnet" "db_subnet_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "db-subnet-1"
  }
}

resource "aws_subnet" "db_subnet_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "db-subnet-2"
  }
}

# DB Subnet Group
resource "aws_db_subnet_group" "main" {
  name       = "main-db-subnet-group"
  subnet_ids = [aws_subnet.db_subnet_1.id, aws_subnet.db_subnet_2.id]

  tags = {
    Name = "main-db-subnet-group"
  }
}

resource "aws_db_instance" "rts" {
  engine               = "mysql"
  instance_class       = "db.t3.micro"
  db_name              = "rtsdb"
  username             = local.example.username
  password             = local.example.password
  engine_version       = "8.0"
  allocated_storage    = 20
  skip_final_snapshot  = true
  db_subnet_group_name = aws_db_subnet_group.main.name
}