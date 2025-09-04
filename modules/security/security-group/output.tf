output "sg_alb_id" {
  description = "ALB Security Group ID"
  value       = aws_security_group.alb.id
}

output "sg_mongo_id" {
  description = "MongoDB Security Group ID"
  value       = aws_security_group.mongo_db.id
}

output "sg_postgres_id" {
  description = "Postgres Security Group ID"
  value       = aws_security_group.postgres_db.id
}

output "sg_redis_id" {
  description = "Redis Security Group ID"
  value       = aws_security_group.redis.id
}

output "sg_ecs_service_ids" {
  description = "Per-service ECS SG IDs"
  value       = { for k, v in aws_security_group.svc : k => v.id }
}

output "vpc_endpoint_sg_id" {
  description = "Redis Security Group ID"
  value       = aws_security_group.vpc_endpoint_sg.id
}