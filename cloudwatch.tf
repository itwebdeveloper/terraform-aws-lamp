resource "aws_cloudwatch_metric_alarm" "low_disk_space_alarm" {
  alarm_actions             = [
    aws_sns_topic.cloudwatch_alarms_topic.arn,
  ]
  alarm_description         = "Alarm triggered when a ${var.application_name} ${var.application_environment} web server has low disk space."
  alarm_name                = "${var.application_slug}-${var.application_environment}-web-low-disk-space-alarm"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = 1
  dimensions                = {
    "InstanceId" = aws_instance.web.id
    "device"     = "nvme0n1p1"
    "fstype"     = "ext4"
    "path"       = "/"
  }
  evaluation_periods        = 1
  metric_name               = "disk_used_percent"
  namespace                 = "CWAgent"
  period                    = 300
  statistic                 = "Average"
  threshold                 = 90
  treat_missing_data        = "missing"

  tags                        = {}
}