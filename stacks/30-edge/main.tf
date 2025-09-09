locals {
  name = "${var.project}-${var.env}"
  tags = merge(var.tags, { Project = var.project, Env = var.env })
  region = var.region

  vpc_id = "vpc-05e4602e06b973291"
  private_route_table_ids = ["rtb-0d83f55e89e8fb64e"]
  private_subnet_ids = ["subnet-0520c9b431facfcbe", "subnet-08b1c187f7889d2d4"]
}

module "endpoint" {
  source        = "../../modules/edge/endpoint"
  name          = local.name
  vpc_id        = local.vpc_id
  region        = local.region
  subnet_ids    = local.private_subnet_ids
  private_route_table_ids = local.private_route_table_ids
}
