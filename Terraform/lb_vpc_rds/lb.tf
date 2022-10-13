# add load balance
# add endpoint output, id
# create 2 stages in jenkinsfile with lb and others

resource "aws_lb" "default" {
  name            = "todo-app-lb"
  subnets         = [for subnet in aws_subnet.public : subnet.id]
  security_groups = [aws_security_group.lb.id]
}

resource "aws_lb_target_group" "todo_app" {
  name        = "todo-app-target-group"
  port        = 8000
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"
}

resource "aws_lb_listener" "todo_app" {
  load_balancer_arn = aws_lb.default.id
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.todo_app.id
    type             = "forward"
  }
}