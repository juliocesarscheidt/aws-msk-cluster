resource "aws_msk_configuration" "msk_cluster_config" {
  kafka_versions    = [var.kafka_version]
  name              = "msk-cluster-config-${var.stage}"
  server_properties = <<PROPERTIES
auto.create.topics.enable=true
default.replication.factor=2
min.insync.replicas=2
num.io.threads=8
num.network.threads=5
num.partitions=12
num.replica.fetchers=2
socket.request.max.bytes=104857600
unclean.leader.election.enable=true
replica.lag.time.max.ms=30000
PROPERTIES
}

resource "aws_msk_cluster" "msk_cluster" {
  cluster_name           = var.kafka_cluster_name
  kafka_version          = var.kafka_version
  number_of_broker_nodes = var.kafka_number_nodes
  broker_node_group_info {
    instance_type   = var.kafka_instance_type
    ebs_volume_size = var.ebs_volume_size
    client_subnets  = aws_subnet.public_subnet.*.id
    security_groups = [aws_security_group.msk_sg.id]
  }
  encryption_info {
    # encryption_at_rest_kms_key_arn = var.kms_key_arn
    encryption_in_transit {
      client_broker = "TLS_PLAINTEXT"
      in_cluster    = true
    }
  }
  configuration_info {
    arn      = aws_msk_configuration.msk_cluster_config.arn
    revision = aws_msk_configuration.msk_cluster_config.latest_revision
  }
  open_monitoring {
    prometheus {
      jmx_exporter {
        enabled_in_broker = true
      }
      node_exporter {
        enabled_in_broker = true
      }
    }
  }
  logging_info {
    broker_logs {
      cloudwatch_logs {
        enabled = false
      }
      firehose {
        enabled = false
      }
      s3 {
        enabled = true
        bucket  = var.kafka_logs_bucket_name
        prefix  = "logs/${var.stage}/"
      }
    }
  }
  tags = merge(var.tags, {
    "NAME" = "msk_cluster_${var.stage}"
  })
  depends_on = [
    aws_msk_configuration.msk_cluster_config
  ]
}
