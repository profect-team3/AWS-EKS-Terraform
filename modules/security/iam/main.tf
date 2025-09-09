# 시크릿 이름 -> ARN 조회
data "aws_secretsmanager_secret" "by_name" {
  for_each = var.secret_names
  name     = each.value
}

# EKS 클러스터 OIDC Issuer URL
# data "aws_eks_cluster" "this" {
#   name = var.eks_cluster_name
# }

# 수동 IAM OIDC Provider
# data "aws_iam_openid_connect_provider" "this" {
#   url = local.oidc_issuer_url
# }

locals {
  service_secret_keys = {
    mcpserver = []
    report = ["POSTGRES"]
    user = ["POSTGRES"]
    store = ["POSTGRES", "DISCORD_URL", "MONGO"]
    auth = ["POSTGRES", "REDIS"]
    order = ["POSTGRES", "REDIS", "DISCORD_URL", "MONGO"]
    payment = ["POSTGRES", "REDIS", "TOSS"]
    review = ["POSTGRES"]
    ai = ["POSTGRES", "OPENAI_API_KEY"]
  }

  all_secret_arns = {for k, _ in var.secret_names : k => data.aws_secretsmanager_secret.by_name[k].arn}

  service_secret_arns = {
    for svc, keys in local.service_secret_keys :
    svc => [for k in keys : local.all_secret_arns[k]]
  }

  # 시크릿이 존재하는 서비스만 별도 맵 (정책/부착에 사용)
  services_with_secrets = {
    for svc, arns in local.service_secret_arns :
    svc => arns if length(arns) > 0
  }

  # JWT 서명 권한이 필요한 서비스 목록
  jwt_kms_services = ["auth"]

  # eks_identity = one(data.aws_eks_cluster.this.identity)
  # eks_oidc_block = one(local.eks_identity.oidc)
  #
  # oidc_issuer_url = local.eks_oidc_block.issuer
  # oidc_host = replace(local.oidc_issuer_url, "https://", "")
}

# 서비스별 IRSA Role
resource "aws_iam_role" "irsa_role" {
  for_each = local.service_secret_arns
  name     = "${var.name}-${each.key}-irsa"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          # Federated = data.aws_iam_openid_connect_provider.this.arn
          Federated = "arn:aws:iam::252098843029:oidc-provider/oidc.eks.ap-northeast-2.amazonaws.com/id/F6E55736763FAF980C336D25962A0B3C"
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = {
            # "${local.oidc_host}:sub" = "system:serviceaccount:${var.namespace}:${each.key}-sa"
            "oidc.eks.ap-northeast-2.amazonaws.com/id/F6E55736763FAF980C336D25962A0B3C:sub" = "system:serviceaccount:${var.namespace}:${each.key}-sa"
          }
        }
      }
    ]
  })
}

# Secrets Manager + KMS Decrypt
data "aws_iam_policy_document" "svc_policy" {
  for_each = local.services_with_secrets

  statement {
    sid       = "ReadSecretsManager"
    effect    = "Allow"
    actions   = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
      "secretsmanager:ListSecretVersionIds"
    ]
    resources = each.value
  }

  statement {
    sid       = "KmsDecryptForSecrets"
    effect    = "Allow"
    actions   = ["kms:Decrypt"]
    resources = [var.kms_key_arn]
  }

  # ── (신규) JWT 서명용 KMS 권한 (auth 등 필요한 서비스에만)
  dynamic "statement" {
    for_each = (
    contains(local.jwt_kms_services, each.key) && var.kms_jwt_key_arn != null
    ) ? [1] : []

    content {
      sid     = "KmsJwtSignVerify"
      effect  = "Allow"
      actions = [
        "kms:GetPublicKey",
        "kms:DescribeKey",
        "kms:Sign",
        "kms:Verify"
      ]
      resources = [var.kms_jwt_key_arn]
    }
  }
}

resource "aws_iam_policy" "svc_policy" {
  for_each = local.services_with_secrets
  name     = "${var.name}-${each.key}-secrets-access"
  policy   = data.aws_iam_policy_document.svc_policy[each.key].json
}

resource "aws_iam_role_policy_attachment" "attach" {
  for_each  = local.services_with_secrets
  role      = aws_iam_role.irsa_role[each.key].name
  policy_arn= aws_iam_policy.svc_policy[each.key].arn
}

