data "terraform_remote_state" "network" {
  backend = "local"
  config = {
    path = "${path.module}/../10-network/terraform.tfstate"
  }
}

data "terraform_remote_state" "security" {
  backend = "local"
  config = {
    path = "${path.module}/../20-security/terraform.tfstate"
  }
}

locals {
  name = "${var.project}-${var.env}"
  tags = merge(var.tags, { Project = var.project, Env = var.env })
  private_subnet_ids = data.terraform_remote_state.network.outputs.private_subnet_ids
  # vpc_id = "vpc-xxxxxxxx"
  # private_subnet_ids = ["subnet-xxxxxxxxxxxxxxxxx"]
  sg_postgres_id = data.terraform_remote_state.security.outputs.sg_postgres_id
  sg_redis_id = data.terraform_remote_state.security.outputs.sg_redis_id
  sg_mongo_id = data.terraform_remote_state.security.outputs.sg_mongo_id
}

# PostgreSQL
module "postgres" {
  # for_each             = toset(local.private_subnet_ids)
  source               = "../../modules/data/ec2-postgres"
  name                 = local.name
  subnet_id            = local.private_subnet_ids[0]
  sg_postgres_id       = local.sg_postgres_id

  ami_id        = coalesce(var.postgres_ami_id, var.ami_id)
  instance_type = coalesce(var.postgres_instance_type, var.instance_type)
  key_name      = coalesce(var.postgres_key_name, var.key_name)

  volume_size = coalesce(var.postgres_volume_size, var.volume_size)
  volume_type = coalesce(var.postgres_volume_type, var.volume_type)
  volume_iops = var.volume_iops

  tags        = local.tags
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
  db_username    = var.db_username
  db_password    = var.db_password
  instance_class = var.docdb_instance_class

  tags = var.tags
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
