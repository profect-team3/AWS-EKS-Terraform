output "rds_instance_id" { value = aws_db_instance.this.id }
output "rds_endpoint" { value = aws_db_instance.this.address  }
output "rds_port" { value = aws_db_instance.this.port }
output "rds_proxy_endpoint" { value = aws_db_proxy.this.endpoint }