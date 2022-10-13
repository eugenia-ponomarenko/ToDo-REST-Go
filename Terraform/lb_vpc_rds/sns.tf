resource "aws_sns_topic" "topic" {
  name = "todo-topic"
}

resource "aws_sns_topic_subscription" "email-target" {
  topic_arn = aws_sns_topic.topic.arn
  protocol  = "email"
  endpoint  = "eugeniaponomarenko01@gmail.com"
}