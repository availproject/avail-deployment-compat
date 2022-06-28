
resource "aws_vpc" "devnet" {
  cidr_block       = var.devnet_vpc_block
  instance_tenancy = "default"

  tags = {
    Name        = "devnet"
    Provisioner = data.aws_caller_identity.provisioner.account_id
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.devnet.id

  tags = {
    Name        = "igw"
    Provisioner = data.aws_caller_identity.provisioner.account_id
  }
}


# Elastic-IP (eip) for NAT
resource "aws_eip" "nat_eip" {
  vpc        = true
  count      = length(var.zones)
  depends_on = [aws_internet_gateway.igw]
}

resource "aws_nat_gateway" "nat" {
  count         = length(var.zones)
  subnet_id     = element(aws_subnet.devnet_public, count.index).id
  allocation_id = element(aws_eip.nat_eip, count.index).id

  tags = {
    Name        = "nat"
    Provisioner = data.aws_caller_identity.provisioner.account_id
  }
}


resource "aws_subnet" "devnet_private" {
  vpc_id            = aws_vpc.devnet.id
  count             = length(var.zones)
  availability_zone = element(var.zones, count.index)
  cidr_block        = element(var.devnet_private_subnet, count.index)
  tags = {
    Name        = "private-subnet"
    Provisioner = data.aws_caller_identity.provisioner.account_id
  }
}

resource "aws_subnet" "devnet_public" {
  vpc_id                  = aws_vpc.devnet.id
  count                   = length(var.zones)
  availability_zone       = element(var.zones, count.index)
  cidr_block              = element(var.devnet_public_subnet, count.index)
  map_public_ip_on_launch = true

  depends_on = [aws_internet_gateway.igw]

  tags = {
    Name        = "public-subnet"
    Provisioner = data.aws_caller_identity.provisioner.account_id
  }
}



resource "aws_route_table" "devnet_private" {
  vpc_id = aws_vpc.devnet.id
  count  = length(var.zones)
  tags = {
    Name        = "private_route_table"
    Provisioner = data.aws_caller_identity.provisioner.account_id
  }
}

resource "aws_route_table" "devnet_public" {
  vpc_id = aws_vpc.devnet.id

  tags = {
    Name        = "public_route_table"
    Provisioner = data.aws_caller_identity.provisioner.account_id
  }
}



# Route for Internet Gateway
resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.devnet_public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

# # Route for NAT
resource "aws_route" "private_nat_gateway" {
  route_table_id         = element(aws_route_table.devnet_private, count.index).id
  destination_cidr_block = "0.0.0.0/0"
  count                  = length(var.zones)
  nat_gateway_id         = element(aws_nat_gateway.nat, count.index).id
}

# Route table associations for both Public & Private Subnets
resource "aws_route_table_association" "public" {
  count          = length(var.zones)
  subnet_id      = element(aws_subnet.devnet_public, count.index).id
  route_table_id = aws_route_table.devnet_public.id
}

resource "aws_route_table_association" "private" {
  count          = length(var.zones)
  subnet_id      = element(aws_subnet.devnet_private, count.index).id
  route_table_id = element(aws_route_table.devnet_private, count.index).id
}

