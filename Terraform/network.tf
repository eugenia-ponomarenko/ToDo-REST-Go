resource "aws_vpc" "main" {
  cidr_block = "172.20.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "ToDo-App-VPC"
  }
}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "ToDo-App-IG"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "172.20.20.0/24"
  availability_zone = "eu-north-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "ToDo-App-public-subnet"
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

resource "aws_route_table_association" "associate_routetable_to_public_subnet" {
  depends_on = [
    aws_subnet.public_subnet,
    aws_route_table.IG_route_table,
  ]
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.IG_route_table.id
}

# resource "aws_subnet" "private_subnet" {
#   vpc_id            = aws_vpc.main.id
#   cidr_block        = "172.20.30.0/24"
#   availability_zone = "eu-north-1a"

#   tags = {
#     Name = "ToDo-App-public-subnet"
#   }
# }

resource "aws_security_group" "EC2_SecurityGroup" {
  name        = "ToDo App SecurityGroup"
  description = "ToDo_APP. SecurityGroup for Ubuntu"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 8000 # app port
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22 # port for Ansible connection
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_security_group" "RDS_SecurityGroup" {
  name        = "ToDo DB. Security Group"
  description = "ToDo. SecurityGroup for RDS"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "PostgreSQL"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_subnet_group" "ToDo_DB_subnet_group" {
  name       = "main"
  subnet_ids = [aws_subnet.public_subnet.id]

  tags = {
    Name = "ToDo DB subnet group"
  }
}