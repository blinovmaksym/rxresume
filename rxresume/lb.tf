resource "aws_lb" "rxresume-alb" {
  name               = "rxresume-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.rxresume-sg.id]
  subnets            = [aws_subnet.public_subnet.id]

  tags = {
    Name = "rxresume-alb"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.rxresume-alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "redirect"
    redirect {
      port       = "3000"
      protocol   = "HTTP"
      status_code = "HTTP_301"
    }
  }
}

# resource "aws_lb_listener" "https" {
#   load_balancer_arn = aws_lb.rxresume-alb.arn
#   port              = 443
#   protocol          = "HTTPS"
#   ssl_policy        = "ELBSecurityPolicy-2016-08"

#   certificate_arn = "<YOUR_SSL_CERTIFICATE_ARN>"

#   default_action {
#     type             = "redirect"
#     redirect {
#       port       = "3000"
#       protocol   = "HTTPS"
#       status_code = "HTTP_301"
#     }
#   }
# }
resource "aws_lb_target_group" "rxresume-tg" {
  name     = "rxresume-tg"
  port     = 3000
  protocol = "HTTP"
  vpc_id   = aws_vpc.rxresume-vpc.id

  health_check {
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 30
  }
}

resource "aws_lb_listener_rule" "http_redirect" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 1

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.rxresume-tg.arn
  }
    condition {
    field  = "host-header"
    values = ["job.buxonline.org.com"]
  }
}

# resource "aws_lb_listener_rule" "https_redirect" {
#   listener_arn = aws_lb_listener.https.arn
#   priority     = 1

#   action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.rxresume-tg.arn
#   }
# }

resource "aws_lb_target_group_attachment" "rxresume-tg-attachment" {
  target_group_arn = aws_lb_target_group.rxresume-tg.arn
  target_id        = aws_instance.ec2_instance.id
}  