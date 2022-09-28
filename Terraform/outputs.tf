output "ec2_ip" {
  value = aws_instance.u_web_server.public_ip
}

output "db_endpoint" {
  value = aws_db_instance.ToDo_RDS_instance.endpoint
}
