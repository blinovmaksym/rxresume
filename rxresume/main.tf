provider "aws" {
  region = "us-east-1"
}

# Создание ключа доступа для RDP
resource "aws_key_pair" "key_pair" {
  key_name   = "ssh_key_pub"
  public_key = var.SSH_KEY
}

resource "aws_vpc" "my_vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
}

# Создание инстанса EC2
resource "aws_instance" "ec2_instance" {
  ami           = "ami-053b0d53c279acc90"
  instance_type = "t2.small"
  key_name      = aws_key_pair.key_pair.key_name
  vpc_id               = aws_vpc.my_vpc.vpc_id
}

