data "aws_secretsmanager_secret" "exec_allowed" {
  for_each = var.secret_names
  name     = each.value
}

locals {
  exec_allowed_secret_arns = [for s in data.aws_secretsmanager_secret.exec_allowed : s.arn]
}

# ECS Task Execution Role
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.name}-ecs-task-execution-role"

  assume_role_policy = jsonencode({
    Version : "2012-10-17",
    Statement : [{
      Effect : "Allow",
      Principal : {
        Service : "ecs-tasks.amazonaws.com"
      },
      Action : "sts:AssumeRole"
    }]
  })
}

# 표준 Execution 권한: ECR Pull + CloudWatch Logs 전송 포함
resource "aws_iam_role_policy_attachment" "attach_managed_exec_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# 시크릿 주입 권한 + KMS 복호화
data "aws_iam_policy_document" "exec_secrets" {
  statement {
    sid       = "ReadSecretsForTask"
    effect    = "Allow"
    actions   = ["secretsmanager:GetSecretValue"]
    resources = local.exec_allowed_secret_arns
  }

  dynamic "statement" {
    for_each = length(local.exec_allowed_secret_arns) > 0 ? [1] : []
    content {
      sid       = "DecryptCMKForSecrets"
      effect    = "Allow"
      actions   = ["kms:Decrypt"]
      resources = [var.kms_key_arn]
    }
  }
}

resource "aws_iam_policy" "exec_secrets" {
  name        = "${var.name}-exec-secrets"
  description = "Secrets Manager read and (optional) KMS decrypt for secrets injection"
  policy      = data.aws_iam_policy_document.exec_secrets.json
}

resource "aws_iam_role_policy_attachment" "attach_exec_secrets" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.exec_secrets.arn
}

resource "aws_iam_role" "ecs_task_role" {
  # for_each = var.service_definitions
  name = "${var.name}-ecsTaskRole" # -${each.key}"

  assume_role_policy = jsonencode({
    Version : "2012-10-17",
    Statement : [{
      Effect : "Allow",
      Principal : {
        Service : "ecs-tasks.amazonaws.com"
      },
      Action : "sts:AssumeRole"
    }]
  })
}

data "aws_iam_policy_document" "ecs_task_lambda_invoke" {
  statement {
    effect = "Allow"
    actions = [
      "lambda:InvokeFunction",
      "lambda:InvokeAsync",
      "lambda:InvokeFunctionUrl"
    ]
    resources = [
      "arn:aws:lambda:${var.region}:${var.account_id}:function:get_public_key_list",
      "arn:aws:lambda:${var.region}:${var.account_id}:function:get_public_key_list:*"
    ]
  }
}

resource "aws_iam_policy" "ecs_task_lambda_invoke" {
  name   = "${var.name}-ecsTaskRole-lambda-invoke"
  policy = data.aws_iam_policy_document.ecs_task_lambda_invoke.json
}

resource "aws_iam_role_policy_attachment" "ecs_task_attach_lambda_invoke" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.ecs_task_lambda_invoke.arn
}