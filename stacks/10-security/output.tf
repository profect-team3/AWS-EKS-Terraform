output "sg_mongo_id" {
  description = "MongoDB Security Group ID"
  value       = module.security_group.sg_mongo_id
}

output "sg_rds_id" {
  description = "Rds Security Group ID"
  value       = module.security_group.sg_rds_id
}

output "sg_rds_proxy_id" {
  description = "Rds Proxy Security Group ID"
  value = module.security_group.sg_rds_proxy_id
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

output "irsa_role_arns" {
  value = module.iam.irsa_role_arns
}

output "bastion_eks" {
  description = "Bastion EKS SG ID"
  value = module.security_group.bastion_eks_sg_id
}