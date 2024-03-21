resource "aws_eks_cluster" "luwan_eks" {
  name     = "${var.prefix_name}-EKS"
  role_arn = aws_iam_role.eks_iam_role.arn

  vpc_config {
    subnet_ids              = aws_subnet.luwan_public_subnet[*].id
    endpoint_private_access = true
    endpoint_public_access  = true
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  # depends_on = [
  #   aws_iam_role_policy_attachment.example-AmazonEKSClusterPolicy,
  #   aws_iam_role_policy_attachment.example-AmazonEKSVPCResourceController,
  # ]

  tags = local.common_tags
}


# resource "aws_eks_node_group" "luwan_node_group" {
#   cluster_name    = aws_eks_cluster.luwan_eks.name
#   node_group_name = "${var.prefix_name}-ng"
#   node_role_arn   = aws_iam_role.eks_iam_role.arn
#   subnet_ids      = [aws_subnet.luwan_private_subnet1.id, aws_subnet.luwan_private_subnet2.id]

#   scaling_config {
#     desired_size = 1
#     max_size     = 2
#     min_size     = 1
#   }

#   launch_template {

#     id      = aws_launch_template.luwan_lt.id
#     version = aws_launch_template.luwan_lt.latest_version
#   }

#   # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
#   # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
#   # depends_on = [
#   #   aws_iam_role_policy_attachment.example-AmazonEKSWorkerNodePolicy,
#   #   aws_iam_role_policy_attachment.example-AmazonEKS_CNI_Policy,
#   #   aws_iam_role_policy_attachment.example-AmazonEC2ContainerRegistryReadOnly,
#   # ]
# }


# module "eks_managed_node_group" {
#   source = "terraform-aws-modules/eks/aws//modules/eks-managed-node-group"

#   name            = "${var.prefix_name}-ng"
#   cluster_name    = aws_eks_cluster.luwan_eks.name
#   cluster_version = aws_eks_cluster.luwan_eks.version

#   subnet_ids = [aws_subnet.luwan_private_subnet1.id, aws_subnet.luwan_private_subnet2.id]

#   min_size     = 1
#   max_size     = 2
#   desired_size = 1

#   instance_types = [var.instance_type]

#   use_custom_launch_template = true

#   launch_template_id      = aws_launch_template.luwan_lt.id
#   launch_template_version = aws_launch_template.luwan_lt.latest_version



#   labels = {
#     Environment = "test"
#   }


#   // The following variables are necessary if you decide to use the module outside of the parent EKS module context.
#   // Without it, the security groups of the nodes are empty and thus won't join the cluster.
#   cluster_primary_security_group_id = aws_security_group.dara_sg.id
#   vpc_security_group_ids            = [aws_security_group.dara_sg.id, "sg-091a1f69a3ad4d83b"]

#   // Note: `disk_size`, and `remote_access` can only be set when using the EKS managed node group default launch template
#   // This module defaults to providing a custom launch template to allow for custom security groups, tag propagation, etc.
#   // use_custom_launch_template = false
#   // disk_size = 50
#   //
#   //  # Remote access cannot be specified with a launch template
#   //  remote_access = {
#   //    ec2_ssh_key               = module.key_pair.key_pair_name
#   //    source_security_group_ids = [aws_security_group.remote_access.id]
#   //  }

# }