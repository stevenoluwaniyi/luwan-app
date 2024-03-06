variable "aws_region" {
  type        = map(string)
  description = "List of aws regions"
  default = {
    us-east-1      = "us-east-1"
    us-east-2      = "us-east-2"
    us-west-1      = "us-west-1"
    us-west-2      = "us-west-2"
    ca-central-1   = "ca-central-1"
    eu-central-1   = "eu-central-1"
    eu-west-1      = "eu-west-1"
    eu-west-2      = "eu-west-2"
    eu-west-3      = "eu-west-3"
    eu-north-1     = "eu-north-1"
    ap-east-1      = "ap-east-1"
    ap-southeast-1 = "ap-southeast-1"
    ap-southeast-2 = "ap-southeast-2"
    ap-northeast-1 = "ap-northeast-1"
    ap-northeast-2 = "ap-northeast-2"
    sa-east-1      = "sa-east-1"
  }
}

variable "enable_monitoring" {
  type    = bool
  default = true
}

variable "ami" {
  type        = map(string)
  description = "List of AMIs"
  default = {
    ami_latest = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
  }
}

variable "cidr_block" {
  type = map(string)
  default = {
    vpc_cidr_block     = "10.0.0.0/16"
    rt_cidr_block      = "0.0.0.0/0"
    ingress_cidr_block = "128.136.104.5/32"
  }
}

variable "public_subnets_cidr_blocks" {
  type    = list(string)
  default = ["10.0.0.0/24", "10.0.1.0/24"]
}

variable "private_subnets_cidr_blocks" {
  type    = list(string)
  default = ["10.0.2.0/24", "10.0.3.0/24"]
}

variable "private_rt_cidr" {
  type    = string
  default = "10.0.0.0/12"
}

variable "my_ip_address" {
  type    = list(string)
  default = ["66.68.114.229/32"]
}

variable "egress_cidr_block" {
  type    = list(string)
  default = ["0.0.0.0/0"]
}


variable "aws_instance_types" {
  type = map(string)
  default = {
    t2_micro  = "t2.micro"
    t3_micro  = "t3.micro"
    t3_small  = "t3.small"
    t3_medium = "t3.medium"
    t3_large  = "t3.large"
  }
}

variable "company_tag" {
  type    = string
  default = "luwan"
}

variable "project_tag" {
  type = string
}

variable "billing_code_tag" {
  type = string
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}