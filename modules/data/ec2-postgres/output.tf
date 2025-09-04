output "postgres_instance_ids"      { value = aws_instance.db.id }
output "postgres_private_ips"       { value = aws_instance.db.private_ip }
output "postgres_private_dns"       { value = aws_instance.db.private_dns}

