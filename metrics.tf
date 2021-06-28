resource "aws_cloudwatch_metric_alarm" "metric_alarm_cpu_high" {
  count               = var.monitoring_enabled == true && var.emails_alert != "" ? var.kafka_number_nodes : 0
  alarm_name          = "metric_alarm_cpu_high_broker_${count.index}_${var.stage}"
  alarm_description   = "CPU utilization has exceeded the threshold"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  unit                = "Percent"
  evaluation_periods  = var.evaluation_periods
  threshold           = var.percent_threshold
  period              = 300 # 5 minutes
  metric_name         = "CpuUser"
  namespace           = "AWS/Kafka"
  statistic           = "Average"
  dimensions = {
    "Cluster Name" = var.kafka_cluster_name
    "Broker ID"    = count.index
  }
  alarm_actions = [aws_sns_topic.msk_cluster_topic.0.arn]
  tags = merge(var.tags, {
    "NAME" = "metric_alarm_cpu_high_broker_${count.index}_${var.stage}"
  })
  depends_on = [
    var.kafka_cluster_name,
    aws_sns_topic.msk_cluster_topic
  ]
}
