resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "Basic-metrics-for-APP"

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
        "title": "EC2 Instance CPU Utilization (in percent)"
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
        "title": "EC2 Instance Network In (in bytes)"
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
        "title": "EC2 Instance Network Out (in bytes)"
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
            "AWS/RDS",
            "CPUUtilization",
            "DBInstanceIdentifier",
            "${aws_db_instance.ToDo_RDS_instance.id}"
          ]
        ],
        "period": 300,
        "stat": "Average",
        "region": "eu-north-1",
        "title": "RDS Instance CPU Utilization (in percent)"
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
            "AWS/RDS",
            "FreeableMemory",
            "DBInstanceIdentifier",
            "${aws_db_instance.ToDo_RDS_instance.id}"
          ]
        ],
        "period": 300,
        "stat": "Average",
        "region": "eu-north-1",
        "title": "RDS Instance Freeable Memory (in bytes)"
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
            "AWS/RDS",
            "FreeStorageSpace",
            "DBInstanceIdentifier",
            "${aws_db_instance.ToDo_RDS_instance.id}"
          ]
        ],
        "period": 300,
        "stat": "Average",
        "region": "eu-north-1",
        "title": "RDS Instance Free Storage Space (in bytes)"
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
            "AWS/RDS",
            "ReadIOPS",
            "DBInstanceIdentifier",
            "${aws_db_instance.ToDo_RDS_instance.id}"
          ]
        ],
        "period": 300,
        "stat": "Average",
        "region": "eu-north-1",
        "title": "RDS Instance Read IOPS"
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
            "AWS/RDS",
            "WriteIOPS",
            "DBInstanceIdentifier",
            "${aws_db_instance.ToDo_RDS_instance.id}"
          ]
        ],
        "period": 300,
        "stat": "Average",
        "region": "eu-north-1",
        "title": "RDS Instance Write IOPS"
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

resource "aws_cloudwatch_metric_alarm" "rds_cpu" {
    alarm_name                = "rds-cpu-utilization"
    comparison_operator       = "GreaterThanOrEqualToThreshold"
    evaluation_periods        = "2"
    metric_name               = "CPUUtilization"
    namespace                 = "AWS/RDS"
    period                    = "120" #seconds
    statistic                 = "Average"
    threshold                 = "70"
    alarm_description         = "ToDo-DB RDS Instance CPU Utilization Alarm"
    insufficient_data_actions = []

    dimensions = {
        DBInstanceIdentifier = aws_db_instance.ToDo_RDS_instance.id
        }
}

resource "aws_cloudwatch_metric_alarm" "rds_free_storage" {
    alarm_name                = "rds-free-storage-space"
    comparison_operator       = "GreaterThanOrEqualToThreshold"
    evaluation_periods        = "2"
    metric_name               = "FreeStorageSpace"
    namespace                 = "AWS/RDS"
    period                    = "120" #seconds
    statistic                 = "Average"
    threshold                 = "70"
    alarm_description         = "ToDo-DB RDS Instance Free Storage Space Alarm"
    insufficient_data_actions = []

    dimensions = {
        DBInstanceIdentifier = aws_db_instance.ToDo_RDS_instance.id
        }
}