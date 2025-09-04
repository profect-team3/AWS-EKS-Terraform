locals {
  name = "${var.project}-${var.env}"
  tags = merge(var.tags, { Project = var.project, Env = var.env })
}

module "state_bucket" {
  source             = "../../modules/s3/state-bucket"
  name               = local.name
  region             = var.region
  tags               = var.tags
}
