
locals {
  common_tags = {
    company      = var.company_tag
    project      = "${var.company_tag}-${var.project_tag}"
    billing_code = var.billing_code_tag
    #Name              = "Darasimi Oluwaniyi"
    #Manager           = "Chris Wahl"
    Market            = "Local"
    Engagement_Office = "Austin"
    #Email             = "darasimi.oluwaniyi@slalom.com"
  }

  compute_tags = {

    Name = "${var.prefix_name}-nginx-${random_integer.small_number.result}"
    # Manager           = "Chris Wahl"
    Market            = "Local"
    Engagement_Office = "Austin"
    #Email             = "darasimi.oluwaniyi@slalom.com"
  }

  alb_sg_tags = {
    "kubernetes.io/cluster/${aws_eks_cluster.luwan_eks.name}" = "owned"
  }

  subnet_alb_tags = {
    "kubernetes.io/role/elb" = 1
  }

  json_data = file("${path.root}/iam_policy.json")

  s3_bucket_name = "${var.prefix_name}-${random_integer.s3.result}-tf"

  instance_type = data.aws_ec2_instance_types.instance_type.instance_types[0]

  prefix_name = var.prefix_name

  resource_default_name = "resource${random_integer.small_number.result}"

  website_content = {
    index = "/website/index.html"
    png   = "/website/Globo_logo_Vert.png"
  }

  combined_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "${data.aws_elb_service_account.main.arn}"
      },
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::${local.s3_bucket_name}/alb-logs/*"
    },
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "delivery.logs.amazonaws.com"
      },
      "Action": [
        "s3:PutObject",
        "s3:GetBucketAcl"
      ],
      "Resource": [
        "arn:aws:s3:::${local.s3_bucket_name}/alb-logs/*",
        "arn:aws:s3:::${local.s3_bucket_name}"
      ],
      "Condition": {
        "StringEquals": {
          "s3:x-amz-acl": "bucket-owner-full-control"
        }
      }
    }
  ]
}
POLICY

  #arn_policy = { "policy1" = aws_iam_policy.combined_policy.arn }

  public_subnet_cidrs = [
    cidrsubnet(var.cidr_block["vpc_cidr_block"], 8, 10), # 10.0.0.0/24
    cidrsubnet(var.cidr_block["vpc_cidr_block"], 8, 11)  # 10.0.1.0/24
  ]

  private_subnet_cidrs = [
    cidrsubnet(var.cidr_block["vpc_cidr_block"], 8, 12), # 10.0.0.0/24
    cidrsubnet(var.cidr_block["vpc_cidr_block"], 8, 13)  # 10.0.1.0/24
  ]



  #   iam_polcies = {
  #     "policy1" = <<POLICY1
  # {
  #   "Version": "2012-10-17",
  #   "Statement": [
  #     {
  #       "Effect": "Allow",
  #       "Principal": {
  #         "AWS": "${data.aws_elb_service_account.main.arn}"
  #       },
  #       "Action": "s3:PutObject",
  #       "Resource": "arn:aws:s3:::${local.s3_bucket_name}/alb-logs/*"
  #     },
  #     {
  #       "Effect": "Allow",
  #       "Principal": {
  #         "Service": "delivery.logs.amazonaws.com"
  #       },
  #       "Action": "s3:PutObject",
  #       "Resource": "arn:aws:s3:::${local.s3_bucket_name}/alb-logs/*",
  #       "Condition": {
  #         "StringEquals": {
  #           "s3:x-amz-acl": "bucket-owner-full-control"
  #         }
  #       }
  #     },
  #     {
  #       "Effect": "Allow",
  #       "Principal": {
  #         "Service": "delivery.logs.amazonaws.com"
  #       },
  #       "Action": "s3:GetBucketAcl",
  #       "Resource": "arn:aws:s3:::${local.s3_bucket_name}"
  #     }
  #   ]
  # }
  # POLICY1
  #     "policy2" = <<POLICY2
  # {
  #   "Version": "2012-10-17",
  #   "Statement": [
  #     {
  #       "Action": [
  #         "s3:*"
  #       ],
  #       "Effect": "Allow",
  #       "Resource": [
  #         "arn:aws:s3:::${local.s3_bucket_name}",
  #         "arn:aws:s3:::${local.s3_bucket_name}/*"
  #       ]
  #     }
  #   ]
  # }
  # POLICY2
  #   }
}


resource "random_integer" "s3" {
  min = 10000
  max = 99999
}

resource "random_integer" "small_number" {
  min = 1
  max = 100
}