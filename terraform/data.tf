data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ami" "eks" {
  most_recent = true
  owners      = ["self", "amazon"]

  filter {
    name   = "name"
    values = ["*eks-node*"]
  }

}

data "aws_ec2_instance_types" "instance_type" {

  filter {
    name   = "instance-type"
    values = [var.instance_type]
  }
}