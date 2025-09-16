# 시크릿 이름 -> ARN 조회
data "aws_secretsmanager_secret" "by_name" {
  for_each = var.secret_names
  name     = each.value
}

# EKS 클러스터 OIDC Issuer URL
data "aws_eks_cluster" "this" {
  name = var.eks_cluster_name
}

locals {
  all_secret_arns = {for k, _ in var.secret_names : k => data.aws_secretsmanager_secret.by_name[k].arn}

  service_secret_arns = {
    for svc, keys in var.service_secret_keys :
    svc => [for k in keys : local.all_secret_arns[k]]
  }

  # 시크릿이 존재하는 서비스만 별도 맵 (정책/부착에 사용)
  services_with_secrets = {
    for svc, arns in local.service_secret_arns :
    svc => arns if length(arns) > 0
  }

  eks_oidc_issuer_url        = try(data.aws_eks_cluster.this.identity[0].oidc[0].issuer, null)
  eks_oidc_issuer_host_path  = local.eks_oidc_issuer_url != null ? replace(local.eks_oidc_issuer_url, "https://", "") : null
}

# 기존에 생성된 IAM OIDC Provider 조회
data "aws_iam_openid_connect_provider" "eks" {
  url = local.eks_oidc_issuer_url
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
          Federated = data.aws_iam_openid_connect_provider.eks.arn
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = {
            "${local.eks_oidc_issuer_host_path}:sub" = "system:serviceaccount:${var.namespace}:${each.key}-sa"
          }
        }
      }
    ]
  })
}

# Secrets Manager + KMS Decrypt
data "aws_iam_policy_document" "svc_policy" {
  for_each = local.services_with_secrets

  # Secrets Manager 읽기
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

  # 공통: KMS decrypt (Secrets 암호화 해제)
  statement {
    sid       = "KmsDecryptForSecrets"
    effect    = "Allow"
    actions   = ["kms:Decrypt"]
    resources = [var.kms_key_arn]
  }

  # auth 서비스만: JWT 서명/검증용 KMS 키 권한
  dynamic "statement" {
    for_each = (each.key == "auth" && var.kms_jwt_key_arn != null) ? [1] : []
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

# AmazonEKSLoadBalancerControllerRole 신뢰관계 수정
data "aws_iam_role" "alb_controller" {
  name = "AmazonEKSLoadBalancerControllerRole"
}

data "aws_iam_policy_document" "alb_controller_irsa_trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [data.aws_iam_openid_connect_provider.eks.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.eks_oidc_issuer_host_path}:sub"
      values   = ["system:serviceaccount:kube-system:aws-load-balancer-controller"]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.eks_oidc_issuer_host_path}:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

# 기존 Role을 Terraform이 관리하도록 정의 (assume_role_policy만 관리)
resource "aws_iam_role" "alb_controller" {
  name               = data.aws_iam_role.alb_controller.name
  assume_role_policy = data.aws_iam_policy_document.alb_controller_irsa_trust.json

  lifecycle {
    ignore_changes = [
      description,
      path,
      max_session_duration,
      permissions_boundary,
      tags,
      inline_policy,
      managed_policy_arns
    ]
  }
}

# ebs-csi-controller-sa 신뢰관계 수정
data "aws_iam_role" "ebs_controller" {
  name = "EbsCsiController-irsa"
}

data "aws_iam_policy_document" "ebs_controller_irsa_trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [data.aws_iam_openid_connect_provider.eks.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.eks_oidc_issuer_host_path}:sub"
      values   = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.eks_oidc_issuer_host_path}:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

# 기존 Role을 Terraform이 관리하도록 정의 (assume_role_policy만 관리)
resource "aws_iam_role" "ebs_controller" {
  name               = data.aws_iam_role.ebs_controller.name
  assume_role_policy = data.aws_iam_policy_document.ebs_controller_irsa_trust.json

  lifecycle {
    ignore_changes = [
      description,
      path,
      max_session_duration,
      permissions_boundary,
      tags,
      inline_policy,
      managed_policy_arns
    ]
  }
}


# jenkins-irsa 신뢰관계 수정
data "aws_iam_role" "jenkins" {
  name = "jenkins-irsa"
}

data "aws_iam_policy_document" "jenkins_irsa_trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [data.aws_iam_openid_connect_provider.eks.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.eks_oidc_issuer_host_path}:sub"
      values   = ["system:serviceaccount:jenkins:jenkins-sa"]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.eks_oidc_issuer_host_path}:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

# 기존 Role을 Terraform이 관리하도록 정의 (assume_role_policy만 관리)
resource "aws_iam_role" "jenkins" {
  name               = data.aws_iam_role.jenkins.name
  assume_role_policy = data.aws_iam_policy_document.jenkins_irsa_trust.json

  lifecycle {
    ignore_changes = [
      description,
      path,
      max_session_duration,
      permissions_boundary,
      tags,
      inline_policy,
      managed_policy_arns
    ]
  }
}


# jenkins-irsa 신뢰관계 수정
data "aws_iam_role" "jenkins_agent" {
  name = "jenkins-agent-irsa"
}

data "aws_iam_policy_document" "jenkins_agent_irsa_trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [data.aws_iam_openid_connect_provider.eks.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.eks_oidc_issuer_host_path}:sub"
      values   = ["system:serviceaccount:jenkins:jenkins-agent-sa"]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.eks_oidc_issuer_host_path}:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

# 기존 Role을 Terraform이 관리하도록 정의 (assume_role_policy만 관리)
resource "aws_iam_role" "jenkins_agent" {
  name               = data.aws_iam_role.jenkins_agent.name
  assume_role_policy = data.aws_iam_policy_document.jenkins_agent_irsa_trust.json

  lifecycle {
    ignore_changes = [
      description,
      path,
      max_session_duration,
      permissions_boundary,
      tags,
      inline_policy,
      managed_policy_arns
    ]
  }
}

# fluentbit-irsa 신뢰관계 수정
data "aws_iam_role" "fluentbit" {
  name = "fluentbit-irsa"
}

data "aws_iam_policy_document" "fluentbit_irsa_trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [data.aws_iam_openid_connect_provider.eks.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.eks_oidc_issuer_host_path}:sub"
      values   = ["system:serviceaccount:logging:fluent-bit"]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.eks_oidc_issuer_host_path}:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

# 기존 Role을 Terraform이 관리하도록 정의 (assume_role_policy만 관리)
resource "aws_iam_role" "fluentbit" {
  name               = data.aws_iam_role.fluentbit.name
  assume_role_policy = data.aws_iam_policy_document.fluentbit_irsa_trust.json

  lifecycle {
    ignore_changes = [
      description,
      path,
      max_session_duration,
      permissions_boundary,
      tags,
      inline_policy,
      managed_policy_arns
    ]
  }
}


# fluentbit-irsa 신뢰관계 수정
data "aws_iam_role" "vector" {
  name = "vector-irsa"
}

data "aws_iam_policy_document" "vector_irsa_trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [data.aws_iam_openid_connect_provider.eks.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.eks_oidc_issuer_host_path}:sub"
      values   = ["system:serviceaccount:logging/vector"]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.eks_oidc_issuer_host_path}:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

# 기존 Role을 Terraform이 관리하도록 정의 (assume_role_policy만 관리)
resource "aws_iam_role" "vector" {
  name               = data.aws_iam_role.vector.name
  assume_role_policy = data.aws_iam_policy_document.vector_irsa_trust.json

  lifecycle {
    ignore_changes = [
      description,
      path,
      max_session_duration,
      permissions_boundary,
      tags,
      inline_policy,
      managed_policy_arns
    ]
  }
}
