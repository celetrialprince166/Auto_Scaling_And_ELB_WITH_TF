# Define the VPC connfiguration Here

# create the VPC

resource "aws_vpc" "custom_vpc" {
  cidr_block = "10.0.0.0/16"

  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "yt-vpc"
  }

}

# create the subnet

variable "vpc_availability_zones" {
  type        = list(string)
  description = "Availability Zone"
  default     = ["us-west-2a", "us-west-2b"]


}

# create a public subnet

resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.custom_vpc.id
  count             = length(var.vpc_availability_zones)
  cidr_block        = cidrsubnet(aws_vpc.custom_vpc.cidr_block, 8, count.index + 1)
  availability_zone = element(var.vpc_availability_zones, count.index)
  tags = {
    Name = "YT Public Subnet ${count.index + 1}"
  }

}

resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.custom_vpc.id
  count             = length(var.vpc_availability_zones)
  cidr_block        = cidrsubnet(aws_vpc.custom_vpc.cidr_block, 8, count.index + 3)
  availability_zone = element(var.vpc_availability_zones, count.index)
  tags = {
    Name = "YT Private Subnet ${count.index + 1}"
  }

}

# create the internet gateway
resource "aws_internet_gateway" "igw_vpc" {
  vpc_id = aws_vpc.custom_vpc.id
  tags = {
    Name = "YT-Internet-Gateway"
  }
}

# create the public routetable

resource "aws_route_table" "yt_route_table_publicsubnet" {

  vpc_id = aws_vpc.custom_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_vpc.id

  }
  tags = {
    Name = "Public Subnet Route Table"
  }

}


# Create Association Between Public subnet and internet gateway

resource "aws_route_table_association" "public_subnet_association" {
  route_table_id = aws_route_table.yt_route_table_publicsubnet.id
  count          = length(var.vpc_availability_zones)
  subnet_id      = element(aws_subnet.public_subnet[*].id, count.index)

}

# Create the elastic IP

resource "aws_eip" "eip" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.igw_vpc]

}

# Create the NAT Gateway 
resource "aws_nat_gateway" "yt_nat_gateway" {
  subnet_id     = element(aws_subnet.private_subnet[*].id, 0)
  allocation_id = aws_eip.eip.id
  depends_on    = [aws_internet_gateway.igw_vpc]
  tags = {
    Name = "YT-Nat Gateway"
  }
}

# create the private routetable

resource "aws_route_table" "yt_route_table_private_subnet" {

  vpc_id = aws_vpc.custom_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.yt_nat_gateway.id

  }
  tags = {
    Name = "Private Subnet Route Table"
  }

}

# Create Association Between Private subnet and Nat gateway

resource "aws_route_table_association" "private_subnet_association" {
  route_table_id = aws_route_table.yt_route_table_private_subnet.id
  count          = length(var.vpc_availability_zones)
  subnet_id      = element(aws_subnet.private_subnet[*].id, count.index)

}