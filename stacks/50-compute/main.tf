locals {
  name = "${var.project}-${var.env}"
  tags = merge(var.tags, { Project = var.project, Env = var.env })
}

# ECR
module "ecr" {
  source            = "../../modules/compute/ecr"
  name              = local.name
  repositories      = keys(var.service_definitions)
  image_mutability  = var.image_mutability
  # scan_on_push     = var.scan_on_push
  # encryption_type  = var.encryption_type
  # kms_key_arn      = var.kms_key_arn

  keep_tag_prefixes = var.keep_tag_prefixes
  keep_any_last     = var.keep_any_last
}
