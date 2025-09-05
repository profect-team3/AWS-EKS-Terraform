output "repository_urls" {
  description = "서비스별 ECR 리포지토리 URL"
  value       = { for k, r in aws_ecr_repository.this : k => r.repository_url }
}

output "repository_names" {
  description = "서비스별 ECR 리포지토리 이름"
  value       = { for k, r in aws_ecr_repository.this : k => r.name }
}

output "repository_arns" {
  value = { for k, r in aws_ecr_repository.this : k => r.arn }
}
