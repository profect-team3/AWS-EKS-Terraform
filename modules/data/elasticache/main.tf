resource "aws_elasticache_subnet_group" "this" {
  name       = "${var.cluster_name}-subnet-group"
  subnet_ids = var.subnet_ids
  description = "Subnet group for ${var.cluster_name}"
}

resource "aws_elasticache_replication_group" "this" {
  replication_group_id          = var.cluster_name
  replication_group_description = var.description
  engine                        = "redis"
  engine_version                = var.engine_version
  node_type                     = var.node_type
  number_cache_clusters         = var.replica_count + 1 # primary + replica
  automatic_failover_enabled    = var.automatic_failover
  multi_az_enabled              = var.multi_az
  subnet_group_name             = aws_elasticache_subnet_group.this.name
  security_group_ids            = var.security_group_ids
  port                          = var.port
  at_rest_encryption_enabled    = var.at_rest_encryption_enabled
  transit_encryption_enabled    = var.transit_encryption_enabled
  parameter_group_name          = var.parameter_group_name
  snapshot_retention_limit = var.snapshot_retention_limit
  log_delivery_configuration {
    log_type           = "slow-log"
    destination_type   = "cloudwatch-logs"
    log_group           = var.log_group_name
  }
}
