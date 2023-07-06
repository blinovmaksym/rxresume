provider "aws" {
  region = "us-east-1"
}

# Создание ключа доступа для RDP
resource "aws_key_pair" "key_pair" {
  key_name   = "ssh_key_pub"
  public_key = var.SSH_KEY
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"


  name                 = "rxresume-vpc"
  cidr                 = "172.16.0.0/16"
  private_subnets      = ["172.16.1.0/24", "172.16.2.0/24", "172.16.3.0/24"]
  public_subnets       = ["172.16.4.0/24", "172.16.5.0/24", "172.16.6.0/24"]
  enable_nat_gateway   = true
  single_nat_gateway   = true
}

# Создание инстанса EC2
resource "aws_instance" "ec2_instance" {
  ami           = "ami-053b0d53c279acc90"
  instance_type = "t2.small"
  key_name      = aws_key_pair.key_pair.key_name
  vpc_security_group_ids = [module.vpc.default_security_group_id]
  subnet_id     = module.vpc.public_subnets[0]
}

