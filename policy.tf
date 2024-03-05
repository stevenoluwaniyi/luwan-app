data "aws_iam_policy_document" "allow_ec2_access" {
  statement {

    actions = [
      "s3:GetObject",
      "s3:ListBucket",
      "s3:PutObject"
    ]

    resources = [
      aws_s3_bucket.luwan_s3.arn,
      "${aws_s3_bucket.luwan_s3.arn}/*",
    ]
  }
}