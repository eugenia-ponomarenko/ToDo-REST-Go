resource "aws_security_group" "EC2_SecurityGroup" {
  name        = "ToDo App SecurityGroup"
  description = "ToDo_APP. SecurityGroup for EC2 instance"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Flask port"
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "port for Ansible connection"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.jenkins_public_ip}/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "RDS_SecurityGroup" {
  name        = "ToDo-DB-Security-Group"
  description = "ToDo. SecurityGroup for RDS instance"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "PostgreSQL port"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["${aws_security_group.EC2_SecurityGroup.id}", "${var.jenkins_public_ip}/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
