output "instance_ids"      { value = aws_instance.mongo_client.id }
output "private_ips"       { value = aws_instance.mongo_client.private_ip }
