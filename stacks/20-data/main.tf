#Local -> subnet = "subnet-xxxxxx" , module -> 로컬의 배열 사용으로 변경 했습니다.
#DocDB -> subnetids 부분은 원래 서브넷을 여러 개 쓰도록 되어 있는데, 아직 테스트 중이므로 list로 반환하기 위해 [local~~[0]]으로 설정 했습니다.
data "terraform_remote_state" "security" {
  backend = "local"
  config = {
    path = "${path.module}/../10-security/terraform.tfstate"
  }
}

data "aws_iam_role" "proxy_role" {
  name = "AWSServiceRoleForRDS"
}

data "aws_secretsmanager_secret" "rds" {
  arn = "arn:aws:secretsmanager:ap-northeast-2:252098843029:secret:prod/rds-KDVpON"
}

locals {
  name = "${var.project}-${var.env}"
  tags = merge(var.tags, { Project = var.project, Env = var.env })
  private_subnet_ids = ["subnet-0520c9b431facfcbe","subnet-08b1c187f7889d2d4"]
  sg_rds_id = data.terraform_remote_state.security.outputs.sg_rds_id
  sg_redis_id = data.terraform_remote_state.security.outputs.sg_redis_id
  sg_mongo_id = data.terraform_remote_state.security.outputs.sg_mongo_id
}

# Redis
module "redis" {
  # for_each             = toset(local.private_subnet_ids)
  source               = "../../modules/data/ec2-redis"
  name                 = local.name
  subnet_id            = local.private_subnet_ids[0]
  sg_redis_id          = local.sg_redis_id

  ami_id        = coalesce(var.redis_ami_id, var.ami_id)
  instance_type = coalesce(var.redis_instance_type, var.instance_type)
  key_name      = coalesce(var.redis_key_name, var.key_name)

  volume_size = coalesce(var.redis_volume_size, var.volume_size)
  volume_type = coalesce(var.redis_volume_type, var.volume_type)
  volume_iops = var.volume_iops

  tags        = local.tags
}

module "docdb" {
  source      = "../../modules/data/docdb"
  name        = local.name
  subnet_ids  = local.private_subnet_ids
  sg_mongo_id = local.sg_mongo_id
  db_username    = var.docdb_username
  db_password    = var.docdb_password
  instance_class = var.docdb_instance_class

  tags = var.tags
}

# RDS
module "rds" {
  source     = "../../modules/data/rds"
  name       = local.name
  subnet_ids = local.private_subnet_ids
  sg_rds_id  = local.sg_rds_id
  tags       = local.tags

  db_username     = var.rds_username
  db_password     = var.rds_password
  db_name         = var.rds_db_name
  engine_version  = var.engine_version
  instance_class  = var.rds_instance_class
  proxy_name      = var.proxy_name
  proxy_secret_arn = "${data.aws_secretsmanager_secret.rds.arn}"
  proxy_role_arn   = data.aws_iam_role.proxy_role.arn
}

#MongoDB
module "mongo" {
  # for_each             = toset(local.private_subnet_ids)
  source               = "../../modules/data/ec2-mongo"
  name                 = local.name
  subnet_id            = local.private_subnet_ids[0]
  sg_mongo_id          = local.sg_mongo_id

  ami_id        = coalesce(var.mongo_ami_id, var.ami_id)
  instance_type = coalesce(var.mongo_instance_type, var.instance_type)
  key_name      = coalesce(var.mongo_key_name, var.key_name)

  volume_size = coalesce(var.mongo_volume_size, var.volume_size)
  volume_type = coalesce(var.mongo_volume_type, var.volume_type)
  volume_iops = var.volume_iops

  tags        = local.tags
}
