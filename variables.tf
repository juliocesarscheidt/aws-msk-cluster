variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "sa-east-1"
}

variable "stage" {
  type        = string
  description = "Stage environment"
  default     = "production"
}

variable "tags" {
  type        = map
  description = "Tags"
  default     = {}
}

variable "kafka_cluster_name" {
  type        = string
  description = "Cluster name"
  default     = "msk-cluster"
}

variable "monitoring_enabled" {
  type        = bool
  description = "Monitoring is enabled or not?"
  default     = true
}

variable "kafka_version" {
  type        = string
  description = "Kafka version"
  default     = "2.2.1"
}

variable "kafka_instance_type" {
  type        = string
  description = "Kafka instance size"
  # vCPU: 2 | Memória(GiB): 8 | 0,21 USD hour
  default = "kafka.m5.large"
}

variable "kafka_number_nodes" {
  type        = number
  description = "Kafka number of nodes"
  default     = 3
}

variable "kms_key_arn" {
  type        = string
  description = "Kafka version"
  default     = ""
}

variable "ebs_volume_size" {
  type        = number
  description = "EBS size"
  default     = 200
}

variable "kafka_logs_bucket_name" {
  type        = string
  description = "Bucket name for logs"
}

variable "emails_alert" {
  type        = string
  description = "Email to receive alerts"
  default     = ""
}

variable "evaluation_periods" {
  type        = number
  description = "Evaluation periods"
  default     = 1
}

variable "percent_threshold" {
  type        = number
  description = "Percent threshold"
  default     = 60
}

