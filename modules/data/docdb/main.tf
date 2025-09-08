# DocumentDB Subnet Group
resource "aws_docdb_subnet_group" "this" {
  name       = "${var.name}-docdb-subnets"
  subnet_ids = var.subnet_ids
}

# DocumentDB Cluster
resource "aws_docdb_cluster" "this" {
  cluster_identifier      = "${var.name}-docdb"
  engine                  = "docdb"
  engine_version          = "5.0.0"
  master_username         = var.db_username
  master_password         = var.db_password
  backup_retention_period = 5
  preferred_backup_window = "07:00-09:00"
  vpc_security_group_ids  = [var.sg_mongo_id]
  db_subnet_group_name    = aws_docdb_subnet_group.this.name
  apply_immediately       = true
  tags                    = var.tags
  skip_final_snapshot = true
}

# Cluster Instances
resource "aws_docdb_cluster_instance" "this" {
  count              = 3
  identifier         = "${var.name}-docdb-${count.index}"
  cluster_identifier = aws_docdb_cluster.this.id
  instance_class     = var.instance_class
  engine             = aws_docdb_cluster.this.engine
  apply_immediately  = true
  tags               = var.tags
}
