resource "aws_iam_role" "ToDo_accessToRDS" {
  name = "ToDo-Access-RDS"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy_attachment" "attach_policy" {
  name       = "Access-EC2-to-RDS"
  roles      = ["${aws_iam_role.ToDo_accessToRDS.name}"]
  policy_arn = "arn:aws:iam::aws:policy/AmazonRDSFullAccess"
}

resource "aws_iam_instance_profile" "ToDo_instance_profile" {
  name = "ToDo_instance_profile"
  role = aws_iam_role.ToDo_accessToRDS.name
}