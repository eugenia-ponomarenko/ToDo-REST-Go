output "db_endpoint" {
  value = aws_db_instance.ToDo_RDS_instance.endpoint
}

output "lb_dns_name" {
  value = aws_lb.default.dns_name
}


output "lb_target_id" {
  value = aws_lb_target_group.todo_app.id
}

output "ecs_sg_id" {
  value = aws_security_group.ECS_SecurityGroup.id
}

output "public_subnet_0" {
  value = aws_subnet.public_subnet.0.id
}

output "public_subnet_1" {
  value = aws_subnet.public_subnet.1.id
}

output "public_subnet_2" {
  value = aws_subnet.public_subnet.2.id
}