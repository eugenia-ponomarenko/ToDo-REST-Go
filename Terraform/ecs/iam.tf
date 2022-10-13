resource "aws_iam_role" "ToDo_accessToRDS" {
  name = "ToDo-Access-RDS"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_policy" "ec2_to_rds" {
  name   = "EC2AccessToRDS"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "rds:*",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_policy_attachment" "attach_policy" {
  name       = "EC2-Access-to-RDS"
  roles      = ["${aws_iam_role.ToDo_accessToRDS.name}"]
  policy_arn = aws_iam_policy.ec2_to_rds.arn
}