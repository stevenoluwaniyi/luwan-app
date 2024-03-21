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

  filter {
    name   = "architecture"
    values = [var.architecture]
  }

}

data "aws_ec2_instance_types" "instance_type" {

  filter {
    name   = "instance-type"
    values = [var.instance_type]
  }
}

data "aws_eks_cluster" "luwan_cluster" {
  name = aws_eks_cluster.luwan_eks.name
}

# data "aws_iam_policy_document" "lb_policy"
# {

# }