data "aws_ssm_parameter" "amzn2_linux" {
  name = var.ami["ami_latest"]
}

# resource "aws_instance" "dara_nginx1" {
#   ami                     = nonsensitive(data.aws_ssm_parameter.amzn2_linux.value)
#   instance_type           = var.aws_instance_types["t2_micro"]
#   subnet_id               = aws_subnet.luwan_public_subnet1.id
#   vpc_security_group_ids  = [aws_security_group.dara_sg.id]
#   iam_instance_profile    = aws_iam_instance_profile.nginx_profile.name
#   depends_on              = [aws_iam_role_policy.allow_s3_all]
#   disable_api_termination = false

#   tags = local.compute_tags

#   user_data = <<EOF
#   #! /bin/bash
#   sudo amazon-linux-extras install -y nginx1
#   sudo service nginx start
#   aws s3 cp s3://${aws_s3_bucket.luwan_s3.id}/website/index.html /home/ec2-user/index.html
#   aws s3 cp s3://${aws_s3_bucket.luwan_s3.id}/website/Globo_logo_Vert.png /home/ec2-user/Globo_logo_Vert.png
#   sudo rm /usr/share/nginx/html/index.html
#   sudo cp /home/ec2-user/index.html /usr/share/nginx/html/index.html
#   sudo cp /home/ec2-user/Globo_logo_Vert.png /usr/share/nginx/html/Globo_logo_Vert.png
#   EOF

# }

# resource "aws_instance" "dara_nginx2" {
#   ami                     = nonsensitive(data.aws_ssm_parameter.amzn2_linux.value)
#   instance_type           = var.aws_instance_types["t2_micro"]
#   subnet_id               = aws_subnet.luwan_public_subnet2.id
#   vpc_security_group_ids  = [aws_security_group.dara_sg.id]
#   iam_instance_profile    = aws_iam_instance_profile.nginx_profile.name
#   depends_on              = [aws_iam_role_policy.allow_s3_all]
#   disable_api_termination = false

#   tags = local.compute_tags

#   user_data = <<EOF
#   #! /bin/bash
#   sudo amazon-linux-extras install -y nginx1
#   sudo service nginx start
#   aws s3 cp s3://${aws_s3_bucket.luwan_s3.id}/website/index.html /home/ec2-user/index.html
#   aws s3 cp s3://${aws_s3_bucket.luwan_s3.id}/website/Globo_logo_Vert.png /home/ec2-user/Globo_logo_Vert.png
#   sudo rm /usr/share/nginx/html/index.html
#   sudo cp /home/ec2-user/index.html /usr/share/nginx/html/index.html
#   sudo cp /home/ec2-user/Globo_logo_Vert.png /usr/share/nginx/html/Globo_logo_Vert.png
#   EOF

# }

# S3 access for instances
resource "aws_iam_role" "allow_nginx_s3" {
  name = "allow_nginx_s3"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  tags = local.common_tags
}


resource "aws_iam_instance_profile" "nginx_profile" {
  name = "nginx_profile"
  role = aws_iam_role.allow_nginx_s3.name

  tags = local.common_tags
}

resource "aws_iam_role_policy" "allow_s3_all" {
  name = "allow_s3_all"
  role = aws_iam_role.allow_nginx_s3.name

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:*"
      ],
      "Effect": "Allow",
      "Resource": [
                "arn:aws:s3:::${local.s3_bucket_name}",
                "arn:aws:s3:::${local.s3_bucket_name}/*"
            ]
    }
  ]
}
EOF

}


# Worker node profile instances for EKS
resource "aws_iam_role" "eks_worker_nodes_role" {
  name = "worker_nodes_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "role-policy-attachment" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  ])

  role       = aws_iam_role.eks_worker_nodes_role.name
  policy_arn = each.value
}

resource "aws_iam_instance_profile" "eks_profile" {
  name = "eks_profile"
  role = aws_iam_role.eks_worker_nodes_role.name

  tags = local.common_tags
}

# resource "aws_iam_role_policy" "worker_nodes_policy" {
#   name = "allow_worker_nodes_eks"
#   role = aws_iam_role.eks_worker_nodes_role.name

#   policy = <<EOF
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Action": [
#         "s3:*"
#       ],
#       "Effect": "Allow",
#       "Resource": [
#                 "arn:aws:s3:::${local.s3_bucket_name}",
#                 "arn:aws:s3:::${local.s3_bucket_name}/*"
#             ]
#     }
#   ]
# }
# EOF

# }



resource "aws_launch_template" "luwan_lt" {
  name = "${var.prefix_name}-LT"

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = 20
      volume_type           = "gp3"
      delete_on_termination = true
    }
  }

  # iam_instance_profile {
  #   name = aws_iam_instance_profile.eks_profile.name
  # }

  # network_interfaces {
  #   associate_public_ip_address = false
  # }

  image_id = data.aws_ami.eks.image_id

  # instance_type = local.instance_type

  monitoring {
    enabled = var.enable_monitoring
  }

  vpc_security_group_ids = [aws_security_group.dara_sg.id, "sg-091a1f69a3ad4d83b"]

  tag_specifications {
    resource_type = "instance"
    tags          = local.common_tags

  }

  #user_data = base64encode("./user_data_eks.sh")

  # user_data = <<-EOF
  #   #! /bin/bash

  #   cat > eks-nodegroup.yaml <<EOF
  #   apiVersion: eksctl.io/v1alpha5
  #   kind: ClusterConfig
  #   metadata:
  #     name: ${aws_eks_cluster.luwan_eks.name}
  #     region: ${aws_vpc.luwan_vpc.region}
  #   managedNodeGroups:
  #   - name: ${var.prefix_name}-ng
  #     launchTemplate:
  #       id: ${aws_launch_template.luwan_lt.id}
  #       version: ${aws_launch_template.luwan_lt.latest_version}
  #   EOF

  #   sudo eksctl create nodegroup --config-file eks-nodegroup.yaml

  # user_data = base64encode(templatefile("${path.root}/user_data_eks.sh",
  #   {
  #     s3_bucket_name = aws_s3_bucket.luwan_s3.id,
  #     eks_name       = aws_eks_cluster.luwan_eks.name,
  #     aws_region     = var.aws_region["us-east-1"],
  #     prefix_name    = var.prefix_name,
  #     lt_template_id = aws_launch_template.luwan_lt.id,
  #     lt_version     = aws_launch_template.luwan_lt.latest_version

  #   })
  # )
}