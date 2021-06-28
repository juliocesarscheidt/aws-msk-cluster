resource "aws_sns_topic" "msk_cluster_topic" {
  count        = var.monitoring_enabled == true && var.emails_alert != "" ? 1 : 0
  name         = "msk_cluster_topic_${var.stage}"
  display_name = "msk_cluster_topic_${var.stage}"
  fifo_topic   = false
  depends_on = [
    aws_msk_cluster.msk_cluster
  ]
}

resource "aws_sns_topic_subscription" "msk_cluster_topic_subscription" {
  count     = var.monitoring_enabled == true && var.emails_alert != "" ? 1 : 0
  topic_arn = aws_sns_topic.msk_cluster_topic.0.arn
  protocol  = "email"
  endpoint  = var.emails_alert
  depends_on = [
    aws_sns_topic.msk_cluster_topic
  ]
}
