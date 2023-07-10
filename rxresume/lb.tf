resource "aws_elb" "rxresume-lb" {
  name               = "rxresume-lb"
  internal           = false
  security_groups = [aws_security_group.rxresume-sg.id]
  subnets = [aws_subnet.public_subnet.id]

  listener {
    instance_port     = 3000  # Порт на вашем EC2-инстансе
    instance_protocol = "http"
    lb_port           = 80  # Порт балансировщика нагрузки
    lb_protocol       = "http"
    
  }
    listener {
    instance_port     = 3100  # Другой порт на вашем EC2-инстансе
    instance_protocol = "http"
    lb_port           = 3100  # Другой порт балансировщика нагрузки
    lb_protocol       = "http"
  }
  instances = [aws_instance.ec2_instance.id] 
#   listener {
#     instance_port     = 3000 # Порт на вашем EC2-инстансе
#     instance_protocol = "http"
#     lb_port           = 443  # Порт балансировщика нагрузки
#     lb_protocol       = "https"
#     ssl_certificate_id = "YOUR_SSL_CERTIFICATE_ID"  # Укажите идентификатор SSL-сертификата
#   }

  health_check {
    target              = "HTTP:80/"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 30
  }

  cross_zone_load_balancing   = true
  idle_timeout               = 400
  connection_draining        = true
  connection_draining_timeout = 300
}

resource "aws_route53_zone" "dns" {
  name     = "job.buxonline.org"
}



