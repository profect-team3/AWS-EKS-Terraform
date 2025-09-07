output "sg_alb_id" {
  description = "ALB Security Group ID"
  value       = aws_security_group.alb.id
}

output "sg_mongo_id" {
  description = "MongoDB Security Group ID"
  value       = aws_security_group.mongo_db.id
}

output "sg_rds_id" {
  description = "Rds Security Group ID"
  value       = aws_security_group.rds.id
}

output "sg_rds_proxy_id" {
  description = "Rds Proxy Security Group ID"
  value = aws_security_group.rds_proxy.id
}

output "sg_redis_id" {
  description = "Redis Security Group ID"
  value       = aws_security_group.redis.id
}

output "bastion_eks_sg_id" {
  description = "Bastion-Eks Security Group ID"
  value       = aws_security_group.bastion_eks.id
}

output "sg_ecs_service_ids" {
  description = "Per-service ECS SG IDs"
  value       = { for k, v in aws_security_group.svc : k => v.id }
}

output "vpc_endpoint_sg_id" {
  description = "Redis Security Group ID"
  value       = aws_security_group.vpc_endpoint_sg.id
}