terraform {
    backend "s3" {
    bucket = "onboarding-tf-backend"
    key    = "todo/terrraform.tfstate"
    region = "eu-central-1"
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region  = "eu-north-1"
}

resource "aws_iam_role" "ToDo_accessToRDS" {
  name = "ToDo-Access-RDS"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy_attachment" "attach_policy" {
  name       = "Access-EC2-to-RDS"
  roles      = ["${aws_iam_role.ToDo_accessToRDS.name}"]
  policy_arn = "arn:aws:iam::aws:policy/AmazonRDSFullAccess"
}

resource "aws_iam_instance_profile" "ToDo_instance_profile" {
  name = "ToDo_instance_profile"
  role = aws_iam_role.ToDo_accessToRDS.name
}

resource "aws_instance" "u_web_server" {
  ami                    = "ami-0368e9f34d2618ed7"  # Ubuntu Server 18.04 LTS (HVM)
  instance_type          = "t3.micro"
  key_name               = "todo_key"
  iam_instance_profile   = aws_iam_instance_profile.ToDo_instance_profile.name
  vpc_security_group_ids = [aws_security_group.EC2_SecurityGroup.id]
  subnet_id              = [aws_subnet.public_subnet.id, aws_subnet.private_subnet.id]

  tags = {
    Name = "ToDo_App"
  }
}

output "ec2_ip" {
  value = aws_instance.u_web_server.public_ip
}

resource "aws_db_instance" "ToDo_RDS_instance" {
  allocated_storage      = 10
  engine                 = "postgres"
  engine_version         = "14.4"
  instance_class         = "db.t3.micro"
  db_name                = "postgres"
  username               = "postgres"
  password               = "postgres"
  parameter_group_name   = "default.postgres14.4"
  skip_final_snapshot    = true
  publicly_accessible    = true
  db_subnet_group_name   = [aws_db_subnet_group.ToDo_DB_subnet_group.id]
  vpc_security_group_ids = [aws_security_group.RDS_SecurityGroup.id]

  tags = {
    Name = "ToDo_RDS_instance"
  }
}

output "db_endpoint" {
  value = aws_db_instance.ToDo_RDS_instance.endpoint
}