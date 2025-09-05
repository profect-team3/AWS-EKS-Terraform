# RDS Subnet Group
resource "aws_db_subnet_group" "this" {
  name       = "${var.name}-rds-subnets"
  subnet_ids = var.subnet_ids
}

# RDS Instance
resource "aws_db_instance" "this" {
  identifier              = "${var.name}-rds"
  engine                  = "postgres"
  engine_version          = var.engine_version
  instance_class          = var.instance_class
  username                = var.db_username
  password                = var.db_password
  db_name                 = var.db_name
  allocated_storage       = 20
  storage_type            = "gp3"
  multi_az                = true
  publicly_accessible     = false
  vpc_security_group_ids  = [var.sg_rds_id]
  db_subnet_group_name    = aws_db_subnet_group.this.name
  backup_retention_period = 0
  storage_encrypted       = true
  apply_immediately       = true
  skip_final_snapshot     = true
  parameter_group_name    = "default.postgres16"
  tags                    = var.tags
}

# RDS Proxy
resource "aws_db_proxy" "this" {
  name                   = var.proxy_name
  engine_family          = "POSTGRESQL"
  idle_client_timeout    = var.proxy_idle_client_timeout
  require_tls            = false
  role_arn               = var.proxy_role_arn
  vpc_security_group_ids = [var.sg_rds_id]
  vpc_subnet_ids         = var.subnet_ids
  auth {
    auth_scheme = "SECRETS"
    description = "Postgres proxy auth"
    iam_auth    = "DISABLED"
    secret_arn_username  = var.proxy_secret_arn_username
    secret_arn_password  = var.proxy_secret_arn_password
  }
  tags = var.tags

  depends_on = [
    aws_db_instance.this
  ]
}

# RDS Proxy Target Group
resource "aws_db_proxy_default_target_group" "this" {
  db_proxy_name = aws_db_proxy.this.name

  connection_pool_config {
    max_connections_percent      = 100
    connection_borrow_timeout    = var.proxy_borrow_timeout
    init_query                   = ""
  }
}

# RDS Proxy Target
resource "aws_db_proxy_target" "this" {
  db_proxy_name         = aws_db_proxy.this.name
  target_group_name     = "default"
  db_instance_identifier = aws_db_instance.this.identifier
}
