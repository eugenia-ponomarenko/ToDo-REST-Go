terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region  = "eu-central-1"
}

resource "aws_vpc" "main" {
  cidr_block = "172.20.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "ToDO-App"
  }
}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "internet-gateway"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "172.20.20.0/24"
  availability_zone = "eu-central-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet"
  }
}

resource "aws_route_table" "IG_route_table" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }

  tags = {
    Name = "IG-route-table"
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

resource "aws_security_group" "ubuntuSecurityGroup" {
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

  ingress {
    from_port   = 5432 # port for PostgreSQL
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

resource "aws_instance" "u_web_server" {
  ami                    = "ami-042ad9eec03638628"  # Ubuntu Server 18.04 LTS (HVM)
  instance_type          = "t2.micro"
  key_name               = "todo_key"
  vpc_security_group_ids = [aws_security_group.ubuntuSecurityGroup.id]
  subnet_id              = aws_subnet.public_subnet.id

  tags = {
    Name = "ToDo App. Docker"
  }
}


output "ip" {
  value = aws_instance.u_web_server.public_ip
}
