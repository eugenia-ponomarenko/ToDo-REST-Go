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
          Service = "ec2.amazonaws.com"
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

resource "aws_iam_instance_profile" "ToDo_instance_profile" {
  name = "ToDo_instance_profile"
  role = aws_iam_role.ToDo_accessToRDS.name
}