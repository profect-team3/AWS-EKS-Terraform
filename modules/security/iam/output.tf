output "irsa_role_arns" {
  description = "Map(service -> IRSA role ARN)"
  value       = { for svc, r in aws_iam_role.irsa_role : svc => r.arn }
}