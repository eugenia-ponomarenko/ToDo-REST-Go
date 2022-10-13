resource "aws_ecs_task_definition" "main" {
  family                   = "todo-app"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 512
  memory                   = 2048
  task_role_arn            = "${aws_iam_role.ToDo_accessToRDS.arn}"

  container_definitions = jsonencode([
    {
      name      = "todo-app"
      image     = "eugenia1p/todo_rest:arm64"
      cpu       = 512
      memory    = 2048
      essential = true
      portMappings = [
        {
          containerPort = 8000
          hostPort      = 8000
        }
      ]
    }
  ])

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "ARM64"
  }
}

resource "aws_ecs_cluster" "main" {
  name = "todo-app-cluster"
}

resource "aws_ecs_service" "todo_app" {
  name             = "todo-app-service"
  cluster          = aws_ecs_cluster.main.id
  task_definition  = aws_ecs_task_definition.main.arn
  desired_count    = "1"
  launch_type      = "FARGATE"

  network_configuration {
    security_groups  = [var.ecs_sg_id]
    subnets          = [var.public_subnet_0, var.public_subnet_1, var.public_subnet_2]
#     assign_public_ip = true
  }

  load_balancer {
    target_group_arn = var.lb_target_arn
    container_name   = "todo-app"
    container_port   = 8000
  }
}
