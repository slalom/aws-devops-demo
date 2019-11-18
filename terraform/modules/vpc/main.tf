
#Create VPC
resource "aws_vpc" "vpc" {
  cidr_block         = "${var.vpc_cidr}"
  enable_dns_support = "true"

  tags {
    Name = "${var.stack_name}-vpc"
    Manager = "${var.tag_manager}"
    Market = "${var.tag_market}"
    "Engagement Office" = "${var.tag_office}"
    Email = "${var.tag_email}"
  }
}

resource "aws_subnet" "public" {
  count                   = "${length(var.availability_zones)}"
  vpc_id                  = "${aws_vpc.vpc.id}"
  cidr_block              = "${var.subnet_public_cidrs[count.index]}"
  availability_zone       = "${var.availability_zones[count.index]}"
  map_public_ip_on_launch = "true"

  tags {
    Name = "${var.stack_name}-vpc-public-${count.index}"
    Manager = "${var.tag_manager}"
    Market = "${var.tag_market}"
    "Engagement Office" = "${var.tag_office}"
    Email = "${var.tag_email}"
  }
}

resource "aws_subnet" "private" {
  count             = "${length(var.availability_zones)}"
  vpc_id            = "${aws_vpc.vpc.id}"
  cidr_block        = "${var.subnet_private_cidrs[count.index]}"
  availability_zone = "${var.availability_zones[count.index]}"

  tags {
    Name = "${var.stack_name}-vpc-private-${count.index}"
    Manager = "${var.tag_manager}"
    Market = "${var.tag_market}"
    "Engagement Office" = "${var.tag_office}"
    Email = "${var.tag_email}"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags {
    Name = "${var.stack_name}-vpc-igw"
    Manager = "${var.tag_manager}"
    Market = "${var.tag_market}"
    "Engagement Office" = "${var.tag_office}"
    Email = "${var.tag_email}"
  }
}

# route table
resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags {
    Name = "${var.stack_name}-vpc-public"
    Manager = "${var.tag_manager}"
    Market = "${var.tag_market}"
    "Engagement Office" = "${var.tag_office}"
    Email = "${var.tag_email}"
  }
}

resource "aws_route" "public_internet_gateway" {
  route_table_id         = "${aws_route_table.public.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.igw.id}"

  timeouts {
    create = "5m"
  }
}

resource "aws_route_table" "private" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags {
    Name = "${var.stack_name}-vpc-private"
    Manager = "${var.tag_manager}"
    Market = "${var.tag_market}"
    "Engagement Office" = "${var.tag_office}"
    Email = "${var.tag_email}"
  }

  lifecycle {
    # When attaching VPN gateways it is common to define aws_vpn_gateway_route_propagation
    # resources that manipulate the attributes of the routing table (typically for the private subnets)
    ignore_changes = ["propagating_vgws"]
  }
}

resource "aws_eip" "nat" {
  vpc = true

  tags {
    Name = "${var.stack_name}-vpc-nat1"
    Manager = "${var.tag_manager}"
    Market = "${var.tag_market}"
    "Engagement Office" = "${var.tag_office}"
    Email = "${var.tag_email}"
  }
}

resource "aws_nat_gateway" "nat" {
  allocation_id = "${aws_eip.nat.id}"
  subnet_id     = "${element(aws_subnet.public.*.id, 0)}"

  tags {
    Name = "${var.stack_name}-vpc-nat1"
    Manager = "${var.tag_manager}"
    Market = "${var.tag_market}"
    "Engagement Office" = "${var.tag_office}"
    Email = "${var.tag_email}"
  }

  depends_on = ["aws_internet_gateway.igw"]
}

resource "aws_route" "private_nat_gateway" {
  route_table_id         = "${aws_route_table.private.id}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${aws_nat_gateway.nat.id}"

  timeouts {
    create = "5m"
  }
}

resource "aws_route_table_association" "private" {
  count = "${length(var.availability_zones)}"

  subnet_id      = "${element(aws_subnet.private.*.id, count.index)}"
  route_table_id = "${aws_route_table.private.id}"
}

resource "aws_route_table_association" "public" {
  count = "${length(var.availability_zones)}"

  subnet_id      = "${element(aws_subnet.public.*.id, count.index)}"
  route_table_id = "${aws_route_table.public.id}"
}

# TODO: Create a Bastion.
resource "aws_security_group" "bastion" {
  vpc_id      = "${aws_vpc.vpc.id}"
  name        = "${var.stack_name}-bastion"
  description = "for ${var.stack_name} bastion instances"

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "73.162.245.41/32", "12.169.213.138/32","72.34.128.248/32","38.104.105.178/32"
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

  tags {
    Name = "${var.stack_name}-bastion"
    Manager = "${var.tag_manager}"
    Market = "${var.tag_market}"
    "Engagement Office" = "${var.tag_office}"
    Email = "${var.tag_email}"
  }
}

resource "aws_instance" "bastion" {
  ami                    = "${var.bastion_ami_id}"
  instance_type          = "${var.bastion_instance_type}"
  subnet_id              = "${element(aws_subnet.public.*.id, 0)}"
  key_name               = "${var.bastion_key_name}"
  vpc_security_group_ids = ["${aws_security_group.bastion.id}"]

  tags {
    Name = "${var.stack_name}-bastion"
    Manager = "${var.tag_manager}"
    Market = "${var.tag_market}"
    "Engagement Office" = "${var.tag_office}"
    Email = "${var.tag_email}"
  }
}