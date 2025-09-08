#Local -> subnet = "subnet-xxxxxx" , module -> 로컬의 배열 사용으로 변경 했습니다, 라우팅 테이블 - rtb-xxxxxxxxx
data "terraform_remote_state" "security" {
  backend = "local"
  config = {
    path = "${path.module}/../10-security/terraform.tfstate"
  }
}

locals {
  name = "${var.project}-${var.env}"
  tags = merge(var.tags, { Project = var.project, Env = var.env })
  region = var.region

  vpc_id = "vpc-05e4602e06b973291"
  private_route_table_ids = ["rtb-0d83f55e89e8fb64e", "rtb-0ef4a4135100431b8"]
  private_subnet_ids = ["subnet-0520c9b431facfcbe", "subnet-08b1c187f7889d2d4"]
  sg_alb_id = data.terraform_remote_state.security.outputs.sg_alb_id
  vpc_endpoint_sg_id = data.terraform_remote_state.security.outputs.vpc_endpoint_sg_id
}

module "endpoint" {
  source        = "../../modules/edge/endpoint"
  name          = local.name
  vpc_id        = local.vpc_id
  region        = local.region
  subnet_ids    = local.private_subnet_ids
  private_route_table_ids = local.private_route_table_ids
  vpc_endpoint_sg_id = local.vpc_endpoint_sg_id
}
