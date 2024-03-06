
locals {
  common_tags = {
    company           = var.company_tag
    project           = "${var.company_tag}-${var.project_tag}"
    billing_code      = var.billing_code_tag
    Name              = "Darasimi Oluwaniyi"
    Manager           = "Chris Wahl"
    Market            = "Local"
    Engagement_Office = "Austin"
    Email             = "darasimi.oluwaniyi@slalom.com"
  }

  s3_bucket_name = "luwan-${random_integer.s3.result}-tf"

  instance_type = data.aws_ec2_instance_types.instance_type.instance_types[0]

}

resource "random_integer" "s3" {
  min = 10000
  max = 99999
}