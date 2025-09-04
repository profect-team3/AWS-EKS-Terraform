# PostgreSQL
# output "postgres_private_ips" {
#   value = { for k, v in module.postgres : k => v.postgres_private_ips }
# }
# output "postgres_instance_id" {
#   value = { for k, v in module.postgres : k => v.postgres_instance_ids }
# }
output "postgres_private_ips" {
  value = module.postgres.postgres_private_ips
}
output "postgres_private_dns" {
  value = module.postgres.postgres_private_dns
}


# Redis
# output "redis_private_ips" {
#   value = { for k, v in module.redis : k => v.redis_private_ips }
# }
output "redis_private_ips" {
  value = module.redis.redis_private_ips
}
# output "redis_instance_id" {
#   value = { for k, v in module.redis : k => v.redis_instance_ids }
# }
output "redis_private_dns" {
  value = module.redis.redis_private_dns
}

# MongoDB
# output "mongo_private_ips" {
#   value = { for k, v in module.mongo : k => v.private_ips }
# }
# output "mongo_instance_id" {
#   value = { for k, v in module.mongo : k => v.instance_ids }
# }

# DocDB
output "docdb_cluster_id" {
  value = module.docdb.docdb_cluster_id
}

output "docdb_instance_ids" {
  value = module.docdb.docdb_instance_ids
}
