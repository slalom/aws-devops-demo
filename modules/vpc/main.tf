#Create VPC
resource "aws_vpc" "vpc" {
  cidr_block         = var.vpc_cidr
  enable_dns_support = "true"

  tags = {
    Name                = "${var.stack_name}-${var.environment}-vpc"
    Manager             = var.tag_manager
    Market              = var.tag_market
    "Engagement Office" = var.tag_office
    Email               = var.tag_email
  }
}

resource "aws_subnet" "public1" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.subnet_public_cidr_1
  availability_zone       = var.availability_zone_1
  map_public_ip_on_launch = "true"

  tags = {
    Name                = "${var.stack_name}-${var.environment}-vpc-public-1"
    Manager             = var.tag_manager
    Market              = var.tag_market
    "Engagement Office" = var.tag_office
    Email               = var.tag_email
  }
}

resource "aws_subnet" "public2" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.subnet_public_cidr_2
  availability_zone       = var.availability_zone_2
  map_public_ip_on_launch = "true"

  tags = {
    Name                = "${var.stack_name}-${var.environment}-vpc-public-2"
    Manager             = var.tag_manager
    Market              = var.tag_market
    "Engagement Office" = var.tag_office
    Email               = var.tag_email
  }
}

resource "aws_subnet" "private1" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.subnet_private_cidr_1
  availability_zone = var.availability_zone_1

  tags = {
    Name                = "${var.stack_name}-${var.environment}-vpc-private-1"
    Manager             = var.tag_manager
    Market              = var.tag_market
    "Engagement Office" = var.tag_office
    Email               = var.tag_email
  }
}

resource "aws_subnet" "private2" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.subnet_private_cidr_2
  availability_zone = var.availability_zone_2

  tags = {
    Name                = "${var.stack_name}-${var.environment}-vpc-private-2"
    Manager             = var.tag_manager
    Market              = var.tag_market
    "Engagement Office" = var.tag_office
    Email               = var.tag_email
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name                = "${var.stack_name}-${var.environment}-vpc-igw"
    Manager             = var.tag_manager
    Market              = var.tag_market
    "Engagement Office" = var.tag_office
    Email               = var.tag_email
  }
}

# route table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name                = "${var.stack_name}-${var.environment}-vpc-public"
    Manager             = var.tag_manager
    Market              = var.tag_market
    "Engagement Office" = var.tag_office
    Email               = var.tag_email
  }
}

resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id

  timeouts {
    create = "5m"
  }

  depends_on = [aws_internet_gateway.igw, aws_route_table.public]
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name                = "${var.stack_name}-${var.environment}-vpc-private"
    Manager             = var.tag_manager
    Market              = var.tag_market
    "Engagement Office" = var.tag_office
    Email               = var.tag_email
  }

  lifecycle {
    # When attaching VPN gateways it is common to define aws_vpn_gateway_route_propagation
    # resources that manipulate the attributes of the routing table (typically for the private subnets)
    ignore_changes = [propagating_vgws]
  }
  depends_on = [aws_internet_gateway.igw, aws_route_table.private]
}

resource "aws_eip" "nat" {
  count = var.build_nat_gateway ? 1 : 0
  vpc   = true

  tags = {
    Name                = "${var.stack_name}-${var.environment}-vpc-nat1"
    Manager             = var.tag_manager
    Market              = var.tag_market
    "Engagement Office" = var.tag_office
    Email               = var.tag_email
  }
}

resource "aws_nat_gateway" "nat" {
  count         = var.build_nat_gateway ? 1 : 0
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public1.id

  tags = {
    Name                = "${var.stack_name}-${var.environment}-vpc-nat1"
    Manager             = var.tag_manager
    Market              = var.tag_market
    "Engagement Office" = var.tag_office
    Email               = var.tag_email
  }

  depends_on = [aws_internet_gateway.igw]
}

resource "aws_route" "private_nat_gateway" {
  count                  = var.build_nat_gateway ? 1 : 0
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat[count.index].id

  timeouts {
    create = "5m"
  }
}

resource "aws_route_table_association" "private1" {
  subnet_id      = aws_subnet.private1.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private2" {
  subnet_id      = aws_subnet.private2.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "public1" {
  subnet_id      = aws_subnet.public1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public2" {
  subnet_id      = aws_subnet.public2.id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "bastion" {
  vpc_id      = aws_vpc.vpc.id
  name        = "${var.stack_name}-${var.environment}-bastion"
  description = "for ${var.stack_name}-${var.environment} bastion instances"

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "45.62.187.72/32",
    ]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

  tags = {
    Name                = "${var.stack_name}-${var.environment}-bastion"
    Manager             = var.tag_manager
    Market              = var.tag_market
    "Engagement Office" = var.tag_office
    Email               = var.tag_email
  }
}

resource "aws_key_pair" "developer" {
  key_name   = "developer-key"
  public_key = var.bastion_public_key
}

resource "aws_instance" "bastion" {
  ami                    = var.bastion_ami_id
  instance_type          = var.bastion_instance_type
  subnet_id              = aws_subnet.public1.id
  key_name               = aws_key_pair.developer.key_name
  vpc_security_group_ids = [aws_security_group.bastion.id]

  tags = {
    Name                = "${var.stack_name}-${var.environment}-bastion"
    Manager             = var.tag_manager
    Market              = var.tag_market
    "Engagement Office" = var.tag_office
    Email               = var.tag_email
  }
}

