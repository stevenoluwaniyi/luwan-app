resource "aws_autoscaling_group" "luwan_asg" {
  vpc_zone_identifier = aws_subnet.luwan_private_subnet[*].id
  desired_capacity    = 2
  max_size            = 4
  min_size            = 1

  launch_template {
    id      = aws_launch_template.luwan_lt.id
    version = "$Latest"
  }
}