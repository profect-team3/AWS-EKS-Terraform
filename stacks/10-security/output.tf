output "sg_alb_id" {
  description = "ALB Security Group ID"
  value       = module.security_group.sg_alb_id
}

output "sg_mongo_id" {
  description = "MongoDB Security Group ID"
  value       = module.security_group.sg_mongo_id
}

output "sg_rds_id" {
  description = "Rds Security Group ID"
  value       = module.security_group.sg_rds_id
}

output "sg_redis_id" {
  description = "Redis Security Group ID"
  value       = module.security_group.sg_redis_id
}

output "sg_ecs_service_ids" {
  description = "Per-service ECS SG IDs"
  value       = module.security_group.sg_ecs_service_ids
}

output "vpc_endpoint_sg_id" {
  description = "VPC Endpoint SG ID"
  value       = module.security_group.vpc_endpoint_sg_id
}

output "ecs_task_execution_role_arn" {
  description = "ecs task execution role arn"
  value       = module.iam.ecs_task_execution_role_arn
}

output "ecs_task_role_arns" {
  description = "ecs task role anrs"
  value       = module.iam.ecs_task_role_arns
}

