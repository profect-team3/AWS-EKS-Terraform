#Local -> subnet = "subnet-xxxxxx" , module -> 로컬의 배열 사용으로 변경 했습니다.
#DocDB -> subnetids 부분은 원래 서브넷을 여러 개 쓰도록 되어 있는데, 아직 테스트 중이므로 list로 반환하기 위해 [local~~[0]]으로 설정 했습니다.

data "aws_secretsmanager_secret" "rds" {
  arn = "arn:aws:secretsmanager:ap-northeast-2:252098843029:secret:prod/rds-KDVpON"
}

locals {
  name = "${var.project}-${var.env}"
  tags = merge(var.tags, { Project = var.project, Env = var.env })
  private_subnet_ids = ["subnet-0520c9b431facfcbe","subnet-08b1c187f7889d2d4"]
}

module "security_group" {
  source   = "../../modules/security/security-group"
  name     = local.name
  tags     = local.tags
  vpc_id   = "vpc-05e4602e06b973291"
  vpc_cidr = "10.0.0.0/16"
}

# Redis
module "redis" {
  # for_each             = toset(local.private_subnet_ids)
  source               = "../../modules/data/ec2-redis"
  name                 = local.name
  subnet_id            = local.private_subnet_ids[0]
  sg_redis_id          = module.security_group.sg_redis_id

  ami_id        = coalesce(var.redis_ami_id, var.ami_id)
  instance_type = coalesce(var.redis_instance_type, var.instance_type)
  key_name      = coalesce(var.redis_key_name, var.key_name)

  volume_size = coalesce(var.redis_volume_size, var.volume_size)
  volume_type = coalesce(var.redis_volume_type, var.volume_type)
  volume_iops = var.volume_iops

  tags        = local.tags
  depends_on = [module.security_group]
}

module "docdb" {
  source      = "../../modules/data/docdb"
  name        = local.name
  subnet_ids  = local.private_subnet_ids
  sg_mongo_id = module.security_group.sg_mongo_id
  db_username    = var.docdb_username
  db_password    = var.docdb_password
  instance_class = var.docdb_instance_class

  tags = var.tags
  depends_on = [module.security_group]
}

# RDS
module "rds" {
  source     = "../../modules/data/rds"
  name       = local.name
  subnet_ids = local.private_subnet_ids
  sg_rds_id  = module.security_group.sg_rds_id
  sg_rds_proxy_id = module.security_group.sg_rds_proxy_id
  tags       = local.tags

  db_username     = var.rds_username
  db_password     = var.rds_password
  db_name         = var.rds_db_name
  engine_version  = var.engine_version
  instance_class  = var.rds_instance_class
  proxy_name      = var.proxy_name
  proxy_secret_arn = "${data.aws_secretsmanager_secret.rds.arn}"
  proxy_role_arn   = "arn:aws:iam::252098843029:role/service-role/rds-proxy-role-1757065715664"
  depends_on = [module.security_group]
}

# ElastiCache
module "elasticache" {
  source              = "../../modules/data/elasticache"
  cluster_name        = "order-elasticache-redis"
  description         = "order-redis"
  engine_version      = "7.0"
  node_type           = "cache.m5.large"
  replica_count       = 1
  port                = 6380
  subnet_ids          = local.private_subnet_ids
  security_group_ids  = [module.security_group.sg_elasticache_id]
  multi_az            = true
  automatic_failover  = true
  transit_encryption_enabled = true
  at_rest_encryption_enabled  = true
  parameter_group_name        = "default.redis7"
  snapshot_retention_limit = 0
  depends_on = [module.security_group]
}
