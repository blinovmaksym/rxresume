provider "aws" {
  region = "us-east-1"
}
data "aws_availability_zones" "available" {}
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
  azs                  = data.aws_availability_zones.available.names
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
# Создание балансировщика нагрузки
resource "aws_lb" "load_balancer" {
  name               = "rxresume-load-balancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [module.vpc.default_security_group_id]
  subnets            = module.vpc.public_subnets
}

# Привязка инстанса EC2 к балансировщику нагрузки
resource "aws_lb_target_group_attachment" "ec2_attachment" {
  target_group_arn = aws_lb.load_balancer.arn
  target_id        = aws_instance.ec2_instance.id
  port             = 80
}
# Обновление безопасной группы для разрешения доступа по SSH
resource "aws_security_group_rule" "ssh_rule" {
  security_group_id = module.vpc.default_security_group_id
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}
