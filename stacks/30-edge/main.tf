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

  private_subnet_ids = local.private_subnet_ids
  vpc_id = "vpc-xxxxxxxx"
  private_route_table_ids = "rtb-xxxxxxx"
  private_subnet_ids = ["subnet-xxxxxxxxxxxxxxxxx", "subnet-xxxxxxxx"]
  sg_alb_id = data.terraform_remote_state.security.outputs.sg_alb_id
  vpc_endpoint_sg_id = data.terraform_remote_state.security.outputs.vpc_endpoint_sg_id
}


# 1) ALB (Private)
module "alb" {
  source            = "../../modules/edge/alb"
  name              = local.name
  vpc_id            = "vpc-xxxxxxx"
  subnet_ids        = local.private_subnet_ids
  sg_alb_id         = local.sg_alb_id
  # alb_certificate_arn = var.alb_certificate_arn
  health_check_path = var.health_check_path
  services          = var.services
  tags              = var.tags
}

# 2) NLB (Private) → ALB 체인
module "nlb" {
  source        = "../../modules/edge/nlb"
  name          = local.name
  vpc_id            = local.vpc_id
  subnet_ids    = local.private_subnet_ids
  listener_ports= [80]
  alb_arn       = module.alb.alb_arn
  tags          = var.tags

  depends_on = [module.alb]
}

module "endpoint" {
  source        = "../../modules/edge/endpoint"
  name          = local.name
  vpc_id        = local.vpc_id
  region        = local.region
  subnet_ids    = local.private_subnet_ids
  private_route_table_ids = local.private_route_table_ids
  vpc_endpoint_sg_id = local.vpc_endpoint_sg_id
  lambda_allowed_function_arns = var.lambda_allowed_function_arns
}
