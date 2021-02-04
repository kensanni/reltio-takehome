resource "aws_vpc" "reltio_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "Reltio VPC"
  }
}

resource "aws_internet_gateway" "reltio_ig" {
  vpc_id = aws_vpc.reltio_vpc.id

  tags = {
    Name = "Reltio igw"
  }
}

resource "aws_subnet" "private_subnet" {
  count                   = length(var.private_subnet_cidr_blocks)
  
  vpc_id                  = aws_vpc.reltio_vpc.id
  cidr_block              = var.private_subnet_cidr_blocks[count.index]
  availability_zone       = var.availability_zones[count.index]

  tags = {
    Name = "Reltio Private Subnet"
  }
}

resource "aws_subnet" "public_subnet" {
  count                   = length(var.public_subnet_cidr_blocks)

  vpc_id                  = aws_vpc.reltio_vpc.id
  cidr_block              = var.public_subnet_cidr_blocks[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "Reltio Public Subnet"
  }
}

resource "aws_route_table" "private_rt" {
  count = length(var.private_subnet_cidr_blocks)

  vpc_id = aws_vpc.reltio_vpc.id
}

resource "aws_route_table" "public_rt" {
  # count = length(var.private_subnet_cidr_blocks)

  vpc_id = aws_vpc.reltio_vpc.id
}

resource "aws_route" "private_route" {
  count                  = length(var.private_subnet_cidr_blocks)

  route_table_id         = aws_route_table.private_rt[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.reltio_nat_gw[count.index].id
}


resource "aws_route" "public_route" {
  # count                  = length(var.private_subnet_cidr_blocks)

  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.reltio_ig.id
}

resource "aws_eip" "nat" {
  count = length(var.public_subnet_cidr_blocks)

  vpc   = true
}

resource "aws_nat_gateway" "reltio_nat_gw" {
  depends_on = [aws_internet_gateway.reltio_ig]
  count      = length(var.public_subnet_cidr_blocks)

  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public_subnet[count.index].id
}


resource "aws_route_table_association" "public_rt" {
  count = length(var.public_subnet_cidr_blocks)

  subnet_id = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "private_rt" {
  count = length(var.private_subnet_cidr_blocks)

  subnet_id = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.private_rt[count.index].id
}
