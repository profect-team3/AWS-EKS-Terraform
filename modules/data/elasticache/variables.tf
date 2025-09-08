variable "cluster_name" {}
variable "description" {
  type = string
  default = "order-eks-elasticache"
}
variable "engine_version" { default = "7.0" }
variable "node_type" { default = "cache.m5.large" }
variable "replica_count" { default = 2 }
variable "port" { default = 6380 }
variable "subnet_ids" { type = list(string) }
variable "security_group_ids" { type = list(string) }
variable "multi_az" { default = true }
variable "automatic_failover" { default = true }
variable "transit_encryption_enabled" { default = true }
variable "at_rest_encryption_enabled" { default = true }
variable "parameter_group_name" { default = "default.redis7" }
variable "snapshot_retention_limit" {
  type = number
  default = 0
}