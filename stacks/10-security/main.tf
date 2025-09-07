locals {
  name = "${var.project}-${var.env}"
  tags = merge(var.tags, { Project = var.project, Env = var.env })
  # vpc_id = "REPLACE_WITH_VPC_ID" # This will need to be passed as a variable
}

module "security_group" {
  source   = "../../modules/security/security-group"
  name     = local.name
  tags     = local.tags
  vpc_id   = "vpc-05e4602e06b973291"
  service_definitions = var.service_definitions
  vpc_cidr = var.vpc_cidr
}

module "iam" {
  source            = "../../modules/security/iam"
  name              = local.name
  tags              = local.tags
  region            = var.region

  account_id        = var.account_id
  eks_cluster_name  = var.eks_cluster_name
  namespace         = var.namespace
  service_definitions = var.service_definitions
  secret_names        = var.secret_names
  kms_key_arn         = var.kms_key_arn
}