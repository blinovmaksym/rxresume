provider "aws" {
  region = "us-east-1"
}
data "aws_availability_zones" "available" {}

# Создание ключа доступа для RDP
resource "aws_key_pair" "key_pair" {
  key_name   = "ssh_key_resume"
  public_key = var.SSH_KEY
}

resource "aws_vpc" "rxresume-vpc" {
     cidr_block = "10.0.0.0/16"
      tags = {
        Name = "rxresume-net"
  }
}

resource "aws_subnet" "public_subnet" {
vpc_id = aws_vpc.rxresume-vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = data.aws_availability_zones.available.names[0]
  tags = {
    Name = "Public-subnet"
  }
}

resource "aws_subnet" "rds_subnet1" {
  vpc_id     = aws_vpc.rxresume-vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone       = data.aws_availability_zones.available.names[1]

  tags = {
    Name = "Private-subnet"
  }
}

resource "aws_subnet" "rds_subnet2" {
  vpc_id     = aws_vpc.rxresume-vpc.id
  cidr_block = "10.0.3.0/24"
  availability_zone       = data.aws_availability_zones.available.names[2]  # Используйте нужную доступную зону


  tags = {
    Name = "Private-subnet"
  }
}

resource "aws_internet_gateway" "rxresume-GW" {
  vpc_id = aws_vpc.rxresume-vpc.id

  tags = {
    Name = "rxresume-GW"
  }
}

resource "aws_route_table" "rxresume-RT" {
  vpc_id = aws_vpc.rxresume-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.rxresume-GW.id
  } 

  tags = {
    Name = "rxresume-RT"
  }
}

resource "aws_route_table_association" "a-front-net" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.rxresume-RT.id
}

resource "aws_security_group" "rxresume-sg" {
name = "ssh-app-web"
vpc_id = aws_vpc.rxresume-vpc.id
ingress {
  description      = "SSH from VPC"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
    from_port = 22
    to_port = 22
    protocol = "tcp"
  }
ingress {
  description      = "For app"
  from_port        = 3000
  to_port          = 3000
  protocol         = "tcp"
  cidr_blocks      = ["0.0.0.0/0"]
}
ingress {
  description      = "For app2"
  from_port        = 3100
  to_port          = 3100
  protocol         = "tcp"
  cidr_blocks      = ["0.0.0.0/0"]
}
ingress {
  description      = "For PostgreSQL"
  from_port        = 5432
  to_port          = 5432
  protocol         = "tcp"
  cidr_blocks      = ["0.0.0.0/0"]
}
// Terraform removes the default rule
  egress {
   from_port = 0
   to_port = 0
   protocol = "-1"
   cidr_blocks = ["0.0.0.0/0"]
 }
   tags = {
    Name = "ssh-sg"
  }
}
# Создание инстанса EC2
resource "aws_instance" "ec2_instance" {
  ami           = "ami-0261755bbcb8c4a84"
  instance_type = "t2.small"
  key_name      = aws_key_pair.key_pair.key_name
  vpc_security_group_ids = [aws_security_group.rxresume-sg.id]
  subnet_id              = aws_subnet.public_subnet.id
  associate_public_ip_address = true
    tags = {
    Name = "app-server"
  }
}
# Создание инстанса RDS (PostGres)
resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds-subnet-group"
  subnet_ids = [aws_subnet.rds_subnet1.id,aws_subnet.rds_subnet2.id]

  tags = {
    Name = "rds-subnet-group"
  }
}
resource "aws_db_instance" "rds_instance" {
  engine               = "postgres"
  engine_version       = "14.7"
  instance_class       = "db.t3.micro"
  allocated_storage    = 20
  db_name              = "postgres"
  storage_type         = "gp2"
  identifier           = "my-rds-instance"
  username             = "postgres"
  password             = "postgres"
  publicly_accessible = false
  db_subnet_group_name = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids = [aws_security_group.rxresume-sg.id]
  skip_final_snapshot  = true

  tags = {
    Name = "rds-instance"
  }
}






