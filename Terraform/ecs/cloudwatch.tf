resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "ToDo-app-serverless-ECS-metrics"

  dashboard_body = <<EOF
{
  "widgets": [
    {
      "type": "metric",
      "x": 0,
      "y": 0,
      "width": 8,
      "height": 5,
      "properties": {
        "metrics": [
          [
            "AWS/ECS",
            "CPUUtilization",
            "ClusterName",
            "${aws_ecs_cluster.main.name}",
            "ServiceName",
            "${aws_ecs_service.todo_app.name}"
          ]
        ],
        "period": 300,
        "stat": "Average",
        "region": "eu-north-1",
        "title": "ECS Cluster CPU Utilization (in percent)"
      }
    },
    {
      "type": "metric",
      "x": 8,
      "y": 0,
      "width": 8,
      "height": 5,
      "properties": {
        "metrics": [
          [
            "AWS/ECS",
            "MemoryUtilization",
            "ClusterName",
            "${aws_ecs_cluster.main.name}",
            "ServiceName",
            "${aws_ecs_service.todo_app.name}"
          ]
        ],
        "period": 300,
        "stat": "Average",
        "region": "eu-north-1",
        "title": "ECS Cluster Memory Utilization (in percent)"
      }
    }
  ]
}
EOF

    depends_on = [
      aws_ecs_cluster.main
    ]
}

resource "aws_cloudwatch_metric_alarm" "rds_cpu" {
    alarm_name                = "todo-ecs-cluster-cpu-utilization"
    comparison_operator       = "GreaterThanOrEqualToThreshold"
    evaluation_periods        = "2"
    metric_name               = "CPUUtilization"
    namespace                 = "AWS/ECS"
    period                    = "120" #seconds
    statistic                 = "Average"
    threshold                 = "70"
    alarm_description         = "ToDo-APP ECS Cluster CPU Utilization Alarm"
    insufficient_data_actions = []
    alarm_actions             = [var.sns_topic_arn]

    dimensions = {
        ClusterName = aws_ecs_cluster.main.name,
        ServiceName = aws_ecs_service.todo_app.name
        }
}

resource "aws_cloudwatch_metric_alarm" "rds_free_storage" {
    alarm_name                = "todo-ecs-cluster-memory-utilization"
    comparison_operator       = "GreaterThanOrEqualToThreshold"
    evaluation_periods        = "2"
    metric_name               = "MemoryUtilization"
    namespace                 = "AWS/ECS"
    period                    = "120" #seconds
    statistic                 = "Average"
    threshold                 = "70"
    alarm_description         = "ToDo-APP ECS Cluster Memory Utilization Alarm"
    insufficient_data_actions = []
    alarm_actions             = [var.sns_topic_arn]

    dimensions = {
        ClusterName = aws_ecs_cluster.main.name,
        ServiceName = aws_ecs_service.todo_app.name
        }
}