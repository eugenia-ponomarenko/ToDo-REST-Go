resource "aws_db_instance" "ToDo_RDS_instance" {
  allocated_storage      = 5
  engine                 = "postgres"
  engine_version         = "14.4"
  instance_class         = "db.t3.micro"
  db_name                = "postgres"
  username               = "postgres"
  password               = var.db_password
  parameter_group_name   = "default.postgres14"
  publicly_accessible    = true
  db_subnet_group_name   = aws_db_subnet_group.default.id
  vpc_security_group_ids = [aws_security_group.RDS_SecurityGroup.id]
  skip_final_snapshot    = true
  final_snapshot_identifier = "Ignore"

  tags = {
    Name = "ToDo_RDS_instance"
  }
}

resource "aws_db_subnet_group" "default" {
  name        = "todo-db-subnet-group"
  description = "Terraform example RDS subnet group"
  subnet_ids  = [aws_subnet.public_subnet.0.id, aws_subnet.public_subnet.1.id, aws_subnet.public_subnet.2.id]

  tags = {
    Name = "ToDo-DB-subnet-group"
  }
}