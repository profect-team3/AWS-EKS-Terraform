locals {
  name = "${var.project}-${var.env}"
  tags = merge(var.tags, { Project = var.project, Env = var.env })
  # vpc_id = "REPLACE_WITH_VPC_ID" # This will need to be passed as a variable
}

module "iam" {
  source            = "../../modules/security/iam"
  name              = local.name
  tags              = local.tags
  region            = var.region

  eks_cluster_name  = var.eks_cluster_name
  namespace         = var.namespace
  secret_names        = var.secret_names
  kms_key_arn         = var.kms_key_arn
}