provider "aws" {
  region = "us-east-1"
}
data "aws_availability_zones" "available" {}
# Создание ключа доступа для RDP
resource "aws_key_pair" "key_pair" {
  key_name   = "ssh_key_resume"
  public_key = var.SSH_KEY
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"


  name                 = "rxresume-vpc"
  cidr                 = "172.16.0.0/16"
  azs                  = data.aws_availability_zones.available.names
  private_subnets      = ["172.16.1.0/24", "172.16.2.0/24"]
  public_subnets       = ["172.16.3.0/24", "172.16.4.0/24"]
  enable_nat_gateway   = true
  single_nat_gateway   = true
}
resource "aws_subnet" "public_subnet" {
  vpc_id                  = module.vpc.vpc_id
  cidr_block              = "172.16.5.0/24"
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "my-public-subnet"
  }
}

resource "aws_internet_gateway" "rxresume-GW" {
  vpc_id = module.vpc.vpc_id

  tags = {
    Name = "rxresume-GW"
  }
}

resource "aws_route_table" "rxresume-RT" {
  vpc_id = module.vpc.vpc_id

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


resource "aws_security_group" "ingress-all-test" {
name = "allow-all-sg"
vpc_id = module.vpc.vpc_id
ingress {
  description      = "SSH from VPC"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
    from_port = 22
    to_port = 22
    protocol = "tcp"
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
  ami           = "ami-053b0d53c279acc90"
  instance_type = "t2.small"
  key_name      = aws_key_pair.key_pair.key_name
  vpc_security_group_ids = [aws_security_group.ingress-all-test.id]
  subnet_id              = aws_subnet.public_subnet.id
  associate_public_ip_address = true
    tags = {
    Name = "app-server"
  }
}

