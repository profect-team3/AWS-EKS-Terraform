# 1) ECR API (Interface)
resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${var.region}.ecr.api"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = var.subnet_ids
  security_group_ids  = [var.vpc_endpoint_sg_id]
  tags = merge(var.tags, { Name = "${var.name}-vpce-ecr-api" })
}

# 2) ECR DKR (Interface)
resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${var.region}.ecr.dkr"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = var.subnet_ids
  security_group_ids  = [var.vpc_endpoint_sg_id]
  tags = merge(var.tags, { Name = "${var.name}-vpce-ecr-dkr" })
}

# 3) S3 (Gateway) - 라우트 테이블 연결
resource "aws_vpc_endpoint" "s3_gw" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${var.region}.s3"
  vpc_endpoint_type = "Gateway"
  tags = merge(var.tags, { Name = "${var.name}-vpce-s3" })
}

resource "aws_vpc_endpoint_route_table_association" "s3_gw_assoc" {
  for_each        = toset(var.private_route_table_ids)
  route_table_id  = each.value
  vpc_endpoint_id = aws_vpc_endpoint.s3_gw.id
}

# Secrets Manager (Interface)
resource "aws_vpc_endpoint" "secretsmanager" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${var.region}.secretsmanager"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = var.subnet_ids
  security_group_ids  = [var.vpc_endpoint_sg_id]
  tags = merge(var.tags, { Name = "${var.name}-vpce-secretsmanager" })
}

# KMS (Interface)
resource "aws_vpc_endpoint" "kms" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${var.region}.kms"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = var.subnet_ids
  security_group_ids  = [var.vpc_endpoint_sg_id]
  tags = merge(var.tags, { Name = "${var.name}-vpce-kms" })
}

# CloudWatch Logs (Interface)
resource "aws_vpc_endpoint" "logs" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${var.region}.logs"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = var.subnet_ids
  security_group_ids  = [var.vpc_endpoint_sg_id]
  tags = merge(var.tags, { Name = "${var.name}-vpce-logs" })
}