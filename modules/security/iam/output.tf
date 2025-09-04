output "ecs_task_execution_role_arn" {
  description = "ecs task execution role arn"
  value       = aws_iam_role.ecs_task_execution_role.arn
}

output "ecs_task_role_arns" {
  description = "ecs task role anrs"
  value       = aws_iam_role.ecs_task_role.arn
  # value       = { for k, v in aws_iam_role.ecs_task_role : k => v.arn }
}
