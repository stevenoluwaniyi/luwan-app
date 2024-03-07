resource "aws_eks_cluster" "luwan_eks" {
  name     = "Luwan EKS"
  role_arn = aws_iam_role.eks_iam_role.arn

  vpc_config {
    subnet_ids = [aws_subnet.darasimi_private_subnet1.id, aws_subnet.darasimi_private_subnet2.id]
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.example-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.example-AmazonEKSVPCResourceController,
  ]

  tags = local.common_tags
}

output "endpoint" {
  value = aws_eks_cluster.luwan_eks.endpoint
}

output "kubeconfig-certificate-authority-data" {
  value = aws_eks_cluster.luwan_eks.certificate_authority[0].data
}