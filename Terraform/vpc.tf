resource "aws_vpc" "main" {
  cidr_block = "172.20.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "ToDo-App-VPC"
  }
}

resource "aws_subnet" "public_subnet" {
  count             = "${length(data.aws_availability_zones.available.names)}"
  vpc_id            = aws_vpc.main.id
  cidr_block        = "172.20.${length(data.aws_availability_zones.available.names) + count.index}.0/24"
  availability_zone = "${element(data.aws_availability_zones.available.names, count.index)}"
  map_public_ip_on_launch = true

  tags = {
    Name = "ToDo-App-public-subnet-${element(data.aws_availability_zones.available.names, count.index)}"
  }
}

resource "aws_route_table" "IG_route_table" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }

  tags = {
    Name = "ToDo-App-IG-route-table"
  }
}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "ToDo-App-IG"
  }
}

resource "aws_route_table_association" "associate_routetable_to_public_subnet" {
  depends_on = [
    aws_subnet.public_subnet,
    aws_route_table.IG_route_table,
  ]
  count          = "${length(data.aws_availability_zones.available.names)}"
  subnet_id      = "${element(aws_subnet.public_subnet.*.id, count.index)}"
  route_table_id = aws_route_table.IG_route_table.id
}