resource "aws_vpc" "threetier" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true

  tags = {
    Name = "${var.idris_prefix}-VPC"
  }
}

resource "aws_internet_gateway" "IGW" {
  vpc_id = aws_vpc.threetier.id

  tags = {
    Name = "${var.idris_prefix}-IGW"
  }
}

data "aws_availability_zones" "AZ" {
    state = "available"
}

resource "aws_subnet" "public" {
    count = 2
  vpc_id = aws_vpc.threetier.id
  cidr_block = var.public_subnet_cidr[count.index]
  availability_zone = data.aws_availability_zones.AZ.names[count.index]
  map_public_ip_on_launch= true

  tags = {
    Name =  "${var.idris_prefix}-public${count.index+1}" }
} 

resource "aws_subnet" "private" {
    count = 2
  vpc_id = aws_vpc.threetier.id
  cidr_block = var.private_subnet_cidr[count.index]
  availability_zone = data.aws_availability_zones.AZ.names[count.index]

  tags = {
    Name =  "${var.idris_prefix}-private${count.index+1}" }
} 
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.threetier.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.IGW.id
  }


  tags = {
    Name = "${var.idris_prefix}-PUBLIC_ROUTE_TABLE"
  }
}

resource "aws_route_table_association" "associte_public_route" {
    count = 2
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_eip" "elastic" {
    count = 2
    domain = "vpc"
    tags = {
        Name = "${var.idris_prefix}-ELASTIC_IP${count.index+1}"
    }
  
}

resource "aws_nat_gateway" "nat" {
    count = 2
  allocation_id = aws_eip.elastic[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = {
    Name = "${var.idris_prefix}-NAT${count.index+1}"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.IGW]
}

resource "aws_route_table" "private_route_table" {
    count = 2
  vpc_id = aws_vpc.threetier.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat[count.index].id
  }


  tags = {
    Name = "${var.idris_prefix}-PRIVATE_ROUTE_TABLE"
  }
}

resource "aws_route_table_association" "associte_private_route" {
    count = 2
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private_route_table[count.index].id
}

resource "aws_subnet" "DATA" {
    count = 2
  vpc_id = aws_vpc.threetier.id
  cidr_block = var.data_subnet_cidr[count.index]
  availability_zone = data.aws_availability_zones.AZ.names[count.index]

  tags = {
    Name =  "${var.idris_prefix}-DATA${count.index+1}" }
}