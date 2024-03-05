#aws_lb

resource "aws_lb" "darasimi_lb" {
  name               = "darasimi-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.dara_alb_sg.id]
  subnets            = [aws_subnet.darasimi_public_subnet1.id, aws_subnet.darasimi_public_subnet2.id]

  tags = local.common_tags
}

#aws_lb_target_group

resource "aws_lb_target_group" "darasimi_tg" {
  name     = "darasimi-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.darasimi_vpc.id
}

#aws_lb_listener

resource "aws_lb_listener" "darasimi_lb_listener" {
  load_balancer_arn = aws_lb.darasimi_lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.darasimi_tg.arn
  }
}

#aws_lb_target_group_attachment
resource "aws_lb_target_group_attachment" "darasimi_tg_attach" {
  target_group_arn = aws_lb_target_group.darasimi_tg.arn
  target_id        = aws_instance.dara_nginx1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "darasimi_tg_attach2" {
  target_group_arn = aws_lb_target_group.darasimi_tg.arn
  target_id        = aws_instance.dara_nginx2.id
  port             = 80
}


#aws_elb_service_account

data "aws_elb_service_account" "main" {}

