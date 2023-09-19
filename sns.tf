resource "aws_sns_topic" "cloudwatch_alarms_topic" {
  name                        = "${var.application_slug}-${var.application_environment}-web-cloudwatch-alarms-topic"
  tags                        = {}
}

resource "aws_sns_topic_subscription" "cloudwatch_alarms_topic_subscription" {
  endpoint                       = var.application_owner_email
  protocol                       = "email"
  topic_arn                      = aws_sns_topic.cloudwatch_alarms_topic.arn
}