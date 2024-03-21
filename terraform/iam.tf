#Role policy for instance

#IAM role for instances
#Instance profile


data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com", "ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "eks_iam_role" {
  name               = "${var.prefix_name}-eks-iam-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "example-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_iam_role.name
}

resource "aws_iam_role_policy_attachment" "example-AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.eks_iam_role.name
}

# resource "aws_iam_role_policy_attachment" "eks_iam_attachment" {
#   policy_arn = aws_iam_policy.eks_policy.arn
#   role       = aws_iam_role.eks_iam_role.name
# }

resource "aws_iam_policy" "lb_policy" {
  name        = "${var.prefix_name}-AWSLoadBalancerControllerIAMPolicy"
  description = "policy for ingress controller"
  policy      = file("${path.root}/iam_policy.json")
}


# resource "aws_iam_policy" "eks_policy" {
#   name        = "${var.prefix_name}-eks-policy"
#   description = "EKS policy"
#   policy      = data.aws_iam_policy_document.assume_role.json
# }
