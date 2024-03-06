##################################################################################
# PROVIDERS
##################################################################################

##################################################################################
# RESOURCES
##################################################################################

# NETWORKING #
resource "aws_vpc" "darasimi_vpc" {
  cidr_block           = var.cidr_block["vpc_cidr_block"]
  enable_dns_hostnames = true
  tags = {
    Name = "darasimi-vpc"
  }

}

resource "aws_internet_gateway" "darasimi_ig" {
  vpc_id = aws_vpc.darasimi_vpc.id
  tags = {
    Name = "darasimi-ig"
  }

}

resource "aws_subnet" "darasimi_public_subnet1" {
  cidr_block              = var.public_subnets_cidr_blocks[0]
  vpc_id                  = aws_vpc.darasimi_vpc.id
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true
  tags = {
    Name = "darasimi-public-subnet-1"
  }
}

resource "aws_subnet" "darasimi_public_subnet2" {
  cidr_block              = var.public_subnets_cidr_blocks[1]
  vpc_id                  = aws_vpc.darasimi_vpc.id
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = true
  tags = {
    Name = "darasimi-public-subnet-2"
  }
}

#PRIVATE SUBNETS

resource "aws_subnet" "darasimi_private_subnet1" {
  cidr_block              = var.private_subnets_cidr_blocks[0]
  vpc_id                  = aws_vpc.darasimi_vpc.id
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = false
  tags = {
    Name = "darasimi-private-subnet-1"
  }
}

resource "aws_subnet" "darasimi_private_subnet2" {
  cidr_block              = var.private_subnets_cidr_blocks[1]
  vpc_id                  = aws_vpc.darasimi_vpc.id
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = false
  tags = {
    Name = "darasimi-private-subnet-2"
  }
}


# ROUTING #
resource "aws_route_table" "darasimi_public_rt" {
  vpc_id = aws_vpc.darasimi_vpc.id

  route {
    cidr_block = var.cidr_block["rt_cidr_block"]
    gateway_id = aws_internet_gateway.darasimi_ig.id
  }
  tags = {
    Name = "darasimi-rt"
  }
}

resource "aws_route_table" "darasimi_private_rt" {
  vpc_id = aws_vpc.darasimi_vpc.id

  route {
    cidr_block = var.private_rt_cidr
    gateway_id = aws_internet_gateway.darasimi_ig.id
  }
  tags = {
    Name = "darasimi-rt"
  }
}

#Route table association

resource "aws_route_table_association" "darasimi_rt_subnet1" {
  subnet_id      = aws_subnet.darasimi_public_subnet1.id
  route_table_id = aws_route_table.darasimi_public_rt.id
}

resource "aws_route_table_association" "darasimi_rt_subnet2" {
  subnet_id      = aws_subnet.darasimi_public_subnet2.id
  route_table_id = aws_route_table.darasimi_public_rt.id
}

resource "aws_route_table_association" "darasimi_rt_private_subnet1" {
  subnet_id      = aws_subnet.darasimi_private_subnet1.id
  route_table_id = aws_route_table.darasimi_private_rt.id
}

resource "aws_route_table_association" "darasimi_rt_private_subnet2" {
  subnet_id      = aws_subnet.darasimi_private_subnet2.id
  route_table_id = aws_route_table.darasimi_private_rt.id
}



# SECURITY GROUPS #
# Nginx security group 
resource "aws_security_group" "dara_sg" {
  name   = "nginx_sg"
  vpc_id = aws_vpc.darasimi_vpc.id

  # HTTP access from anywhere
  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    #cidr_blocks = var.my_ip_address[0]
    security_groups = [aws_security_group.dara_alb_sg.id]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = var.egress_cidr_block
  }
  tags = {
    Name = "darasimi-sg"
  }
}

resource "aws_security_group" "dara_alb_sg" {
  name   = "dara_nginx_alb"
  vpc_id = aws_vpc.darasimi_vpc.id

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
  tags = {
    Name = "darasimi-sg"
  }
}

# INSTANCES #







