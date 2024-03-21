resource "aws_ecr_repository" "luwan_ecr" {
  name                 = "${var.prefix_name}-ecr"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}