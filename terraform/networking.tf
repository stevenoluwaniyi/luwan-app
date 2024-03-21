##################################################################################
# PROVIDERS
##################################################################################

##################################################################################
# RESOURCES
##################################################################################

# NETWORKING #
resource "aws_vpc" "luwan_vpc" {
  cidr_block           = cidrsubnet(var.cidr_block["vpc_cidr_block"], 0, 0)
  enable_dns_hostnames = true
  tags = {
    Name = "${var.prefix_name}-vpc"
  }
}

resource "aws_internet_gateway" "luwan_ig" {
  vpc_id = aws_vpc.luwan_vpc.id
  tags = {
    Name = "${var.prefix_name}-ig"
  }

}

resource "aws_subnet" "luwan_public_subnet" {
  count                   = var.public_subnets_count
  cidr_block              = local.public_subnet_cidrs[count.index]
  vpc_id                  = aws_vpc.luwan_vpc.id
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
  tags = merge(local.common_tags, local.subnet_alb_tags, {
    Name = "${var.prefix_name}-public-subnet-${count.index}"
  })
}

#PRIVATE SUBNETS

resource "aws_subnet" "luwan_private_subnet" {

  count                   = var.private_subnets_count
  cidr_block              = local.private_subnet_cidrs[count.index]
  vpc_id                  = aws_vpc.luwan_vpc.id
  map_public_ip_on_launch = false
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  tags = {
    Name = "${var.prefix_name}-private-subnet-${count.index}"
  }
}

#EIP
resource "aws_eip" "luwan_eip" {

  count = var.eip_count
  #depends_on = [aws_internet_gateway.luwan_ig]

  tags = {
    Name = "${var.prefix_name}-eip-${count.index}"
  }
}

#NAT GATEWAY

resource "aws_nat_gateway" "luwan_nat_gw" {

  allocation_id = aws_eip.luwan_eip[0].id
  subnet_id     = aws_subnet.luwan_public_subnet[0].id
  #secondary_allocation_ids = aws_eip.luwan_eip[*].id

  tags = {
    Name = "${var.prefix_name}-gw"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  #depends_on = [aws_eip.luwan_eip]
}



# ROUTING #
resource "aws_route_table" "luwan_public_rt" {
  vpc_id = aws_vpc.luwan_vpc.id

  route {
    cidr_block = var.cidr_block["rt_cidr_block"]
    gateway_id = aws_internet_gateway.luwan_ig.id
  }
  tags = {
    Name = "${var.prefix_name}-rt"
  }
}

resource "aws_route_table" "luwan_private_rt" {
  vpc_id = aws_vpc.luwan_vpc.id

  route {
    cidr_block     = var.cidr_block["rt_cidr_block"]
    nat_gateway_id = aws_nat_gateway.luwan_nat_gw.id
  }
  tags = {
    Name = "${var.prefix_name}-rt"
  }


}

# resource "aws_route_table" "luwan_private_rt" {
#   vpc_id = aws_vpc.luwan_vpc.id

#   # route {
#   #   cidr_block     = var.private_rt_cidr
#   #   nat_gateway_id = aws_nat_gateway.luwan_nat_gw1.id
#   # }

#   # route {
#   #   cidr_block     = var.private_rt_cidr
#   #   nat_gateway_id = aws_nat_gateway.luwan_nat_gw2.id
#   # }

#   tags = {
#     Name = "${var.prefix_name}-rt"
#   }
# }

#Route table association

#Public
resource "aws_route_table_association" "luwan_rt_subnet" {
  count          = var.public_subnets_count
  subnet_id      = aws_subnet.luwan_public_subnet[count.index].id
  route_table_id = aws_route_table.luwan_public_rt.id
}



#Private
resource "aws_route_table_association" "luwan_rt_private_subnet" {
  count = var.private_subnets_count
  #subnet_id      = aws_subnet.luwan_private_subnet[count.index].id
  #route_table_id = aws_route_table.luwan_private_rt.id
  subnet_id      = aws_subnet.luwan_private_subnet[count.index].id
  route_table_id = aws_route_table.luwan_private_rt.id
}



# SECURITY GROUPS #
# Nginx security group 
resource "aws_security_group" "dara_sg" {
  name   = "${var.prefix_name}-nginx-sg"
  vpc_id = aws_vpc.luwan_vpc.id

  # HTTP access from anywhere
  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    #cidr_blocks = var.my_ip_address[0]
    security_groups = [aws_security_group.dara_alb_sg.id, "sg-091a1f69a3ad4d83b"]
  }

  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"
    #cidr_blocks = var.my_ip_address[0]
    security_groups = [aws_security_group.dara_alb_sg.id, "sg-091a1f69a3ad4d83b"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = var.egress_cidr_block
  }
  tags = merge(local.common_tags, local.subnet_alb_tags, {
    Name = "${var.prefix_name}-sg"
  })
}

resource "aws_security_group" "dara_alb_sg" {
  name   = "${var.prefix_name}-nginx-alb"
  vpc_id = aws_vpc.luwan_vpc.id

  # HTTP access from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.my_ip_address[0]]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = var.egress_cidr_block
  }
  
  tags = merge(local.common_tags, local.subnet_alb_tags, {
    Name = "${var.prefix_name}alb-sg"
  })
}

# INSTANCES #







