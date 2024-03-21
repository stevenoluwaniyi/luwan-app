module "eks_eks-managed-node-group" {
  source  = "terraform-aws-modules/eks/aws//modules/eks-managed-node-group"
  version = "20.5.3"

  name         = "${var.prefix_name}-ng"
  cluster_name = aws_eks_cluster.luwan_eks.name

  subnet_ids = aws_subnet.luwan_public_subnet[*].id

  min_size     = 2
  max_size     = 6
  desired_size = 5

  instance_types = [var.instance_type]

  use_custom_launch_template = false
  #enable_bootstrap_user_data = true

  # launch_template_id      = aws_launch_template.luwan_lt.id
  # launch_template_version = aws_launch_template.luwan_lt.latest_version
  create_launch_template = true
  launch_template_name   = "${var.prefix_name}-lt"

  block_device_mappings = {
    xvda = {
      device_name = "/dev/xvda"
      ebs = {
        volume_size           = 50
        volume_type           = "gp3"
        delete_on_termination = true
      }
    }
  }


  cluster_auth_base64 = base64encode(data.aws_eks_cluster.luwan_cluster.certificate_authority[0].data)

  cluster_endpoint = data.aws_eks_cluster.luwan_cluster.endpoint

  labels = local.compute_tags


  // The following variables are necessary if you decide to use the module outside of the parent EKS module context.
  // Without it, the security groups of the nodes are empty and thus won't join the cluster.
  cluster_primary_security_group_id = aws_security_group.dara_sg.id
  vpc_security_group_ids            = [aws_security_group.dara_sg.id, "sg-091a1f69a3ad4d83b", aws_security_group.dara_alb_sg.id]

  #iam_role_additional_policies = local.arn_policy

  # user_data_template_path = templatefile("${path.root}/user_data_eks.sh",
  #   {
  #     s3_bucket_name = aws_s3_bucket.luwan_s3.id,
  #     eks_name       = aws_eks_cluster.luwan_eks.name,
  #     aws_region     = var.aws_region["us-east-1"],
  #     prefix_name    = var.prefix_name,
  #     lt_template_id = aws_launch_template.luwan_lt.id,
  #     lt_version     = aws_launch_template.luwan_lt.latest_version

  # })


  // Note: `disk_size`, and `remote_access` can only be set when using the EKS managed node group default launch template
  // This module defaults to providing a custom launch template to allow for custom security groups, tag propagation, etc.
  // use_custom_launch_template = false
  // disk_size = 50
  //
  //  # Remote access cannot be specified with a launch template
  //  remote_access = {
  //    ec2_ssh_key               = module.key_pair.key_pair_name
  //    source_security_group_ids = [aws_security_group.remote_access.id]
  //  }

}