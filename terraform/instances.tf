data "aws_ssm_parameter" "amzn2_linux" {
  name = var.ami["ami_latest"]
}

resource "aws_instance" "dara_nginx1" {
  ami                    = nonsensitive(data.aws_ssm_parameter.amzn2_linux.value)
  instance_type          = var.aws_instance_types["t2_micro"]
  subnet_id              = aws_subnet.darasimi_public_subnet1.id
  vpc_security_group_ids = [aws_security_group.dara_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.nginx_profile.name
  depends_on             = [aws_iam_role_policy.allow_s3_all]

  tags = local.common_tags

  user_data = <<EOF
  #! /bin/bash
  sudo amazon-linux-extras install -y nginx1
  sudo service nginx start
  aws s3 cp s3://${aws_s3_bucket.luwan_s3.id}/website/index.html /home/ec2-user/index.html
  aws s3 cp s3://${aws_s3_bucket.luwan_s3.id}/website/Globo_logo_Vert.png /home/ec2-user/Globo_logo_Vert.png
  sudo rm /usr/share/nginx/html/index.html
  sudo cp /home/ec2-user/index.html /usr/share/nginx/html/index.html
  sudo cp /home/ec2-user/Globo_logo_Vert.png /usr/share/nginx/html/Globo_logo_Vert.png
  EOF

}

resource "aws_instance" "dara_nginx2" {
  ami                    = nonsensitive(data.aws_ssm_parameter.amzn2_linux.value)
  instance_type          = var.aws_instance_types["t2_micro"]
  subnet_id              = aws_subnet.darasimi_public_subnet2.id
  vpc_security_group_ids = [aws_security_group.dara_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.nginx_profile.name
  depends_on             = [aws_iam_role_policy.allow_s3_all]

  tags = local.common_tags

  user_data = <<EOF
  #! /bin/bash
  sudo amazon-linux-extras install -y nginx1
  sudo service nginx start
  aws s3 cp s3://${aws_s3_bucket.luwan_s3.id}/website/index.html /home/ec2-user/index.html
  aws s3 cp s3://${aws_s3_bucket.luwan_s3.id}/website/Globo_logo_Vert.png /home/ec2-user/Globo_logo_Vert.png
  sudo rm /usr/share/nginx/html/index.html
  sudo cp /home/ec2-user/index.html /usr/share/nginx/html/index.html
  sudo cp /home/ec2-user/Globo_logo_Vert.png /usr/share/nginx/html/Globo_logo_Vert.png
  EOF

}

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

resource "aws_launch_template" "luwan_lt" {
  name = "luwan_lt"

  block_device_mappings {
    device_name = "/dev/sda"

    ebs {
      volume_size = 20
    }
  }

  cpu_options {
    core_count       = 4
    threads_per_core = 2
  }


  disable_api_termination = true

  ebs_optimized = true


  iam_instance_profile {
    name = "test"
  }

  image_id = data.aws_ami.eks.image_id

  instance_type = data.aws_ec2_instance_types.instance_type.instance_types[0]

  monitoring {
    enabled = var.enable_monitoring
  }

  placement {
    availability_zone = data.aws_availability_zones.available.names[0]
  }

  vpc_security_group_ids = [aws_security_group.dara_sg.id]

  tag_specifications {
    resource_type = "instance"
    tags          = local.common_tags

  }

  user_data = base64encode(<<EOF
  #! /bin/bash
  sudo amazon-linux-extras install -y nginx1
  sudo service nginx start
  aws s3 cp s3://${aws_s3_bucket.luwan_s3.id}/website/index.html /home/ec2-user/index.html
  aws s3 cp s3://${aws_s3_bucket.luwan_s3.id}/website/Globo_logo_Vert.png /home/ec2-user/Globo_logo_Vert.png
  sudo rm /usr/share/nginx/html/index.html
  sudo cp /home/ec2-user/index.html /usr/share/nginx/html/index.html
  sudo cp /home/ec2-user/Globo_logo_Vert.png /usr/share/nginx/html/Globo_logo_Vert.png
  EOF
  )
}