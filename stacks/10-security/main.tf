data "terraform_remote_state" "network" {
  backend = "local"
  config = {
    path = "${path.module}/../10-network/terraform.tfstate"
  }
}

locals {
  name = "${var.project}-${var.env}"
  tags = merge(var.tags, { Project = var.project, Env = var.env })
  vpc_id = data.terraform_remote_state.network.outputs.vpc_id
}

module "security_group" {
  source   = "../../modules/security/security-group"
  name     = local.name
  tags     = local.tags
  vpc_id   = local.vpc_id
  service_definitions = var.service_definitions
  vpc_cidr = var.vpc_cidr
}

module "iam" {
  source   = "../../modules/security/iam"
  name     = local.name
  tags     = local.tags
  service_definitions = var.service_definitions
  secret_names = var.secret_names
  kms_key_arn  = var.kms_key_arn
  region       = var.region
  account_id   = var.account_id
}