#aws_lb

resource "aws_lb" "luwan_lb" {
  name               = "${var.prefix_name}-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.dara_alb_sg.id]
  subnets            = aws_subnet.luwan_public_subnet[*].id

  tags = merge(local.common_tags, local.alb_sg_tags)
}

#aws_lb_target_group

resource "aws_lb_target_group" "luwan_tg" {
  name     = "${var.prefix_name}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.luwan_vpc.id
}

#aws_lb_listener

resource "aws_lb_listener" "luwan_lb_listener" {
  load_balancer_arn = aws_lb.luwan_lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.luwan_tg.arn
  }
}

#aws_lb_target_group_attachment
# resource "aws_lb_target_group_attachment" "luwan_tg_attach" {
#   target_group_arn = aws_lb_target_group.luwan_tg.arn
#   target_id        = aws_instance._nginx1.id
#   port             = 80
# }

# resource "aws_lb_target_group_attachment" "luwan_tg_attach2" {
#   target_group_arn = aws_lb_target_group.luwan_tg.arn
#   target_id        = aws_instance.dara_nginx2.id
#   port             = 80
# }


#aws_elb_service_account

data "aws_elb_service_account" "main" {}

