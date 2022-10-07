resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "Basic-metrics-for-app-instance"

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
            "AWS/EC2",
            "CPUUtilization",
            "InstanceId",
            "${aws_instance.u_web_server.id}"
          ]
        ],
        "period": 300,
        "stat": "Average",
        "region": "eu-north-1",
        "title": "Instance CPU"
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
            "AWS/EC2",
            "NetworkIn",
            "InstanceId",
            "${aws_instance.u_web_server.id}"
          ]
        ],
        "period": 300,
        "stat": "Average",
        "region": "eu-north-1",
        "title": "Instance Network In (in bytes)"
      }
    },
    {
      "type": "metric",
      "x": 16,
      "y": 0,
      "width": 8,
      "height": 5,
      "properties": {
        "metrics": [
          [
            "AWS/EC2",
            "NetworkOut",
            "InstanceId",
            "${aws_instance.u_web_server.id}"
          ]
        ],
        "period": 300,
        "stat": "Average",
        "region": "eu-north-1",
        "title": "Instance Network Out (in bytes)"
      }
    },
    {
      "type": "metric",
      "x": 0,
      "y": 0,
      "width": 8,
      "height": 5,
      "properties": {
        "metrics": [
          [
            "AWS/EC2",
            "DiskWriteBytes",
            "InstanceId",
            "${aws_instance.u_web_server.id}"
          ]
        ],
        "period": 300,
        "stat": "Average",
        "region": "eu-north-1",
        "title": "Instance Disk Write (in bytes)"
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
            "AWS/EC2",
            "DiskReadBytes",
            "InstanceId",
            "${aws_instance.u_web_server.id}"
          ]
        ],
        "period": 300,
        "stat": "Average",
        "region": "eu-north-1",
        "title": "Instance Disk Read (in bytes)"
      }
    }
  ]
}
EOF

    depends_on = [
      aws_instance.u_web_server
    ]
}

resource "aws_cloudwatch_metric_alarm" "ec2_cpu" {
    alarm_name                = "ec2-cpu-utilization"
    comparison_operator       = "GreaterThanOrEqualToThreshold"
    evaluation_periods        = "2"
    metric_name               = "CPUUtilization"
    namespace                 = "AWS/EC2"
    period                    = "120" #seconds
    statistic                 = "Average"
    threshold                 = "70"
    alarm_description         = "ToDo-App EC2 Instance CPU Utilization Alarm"
    insufficient_data_actions = []

    dimensions = {
        InstanceId = aws_instance.u_web_server.id
        }
}