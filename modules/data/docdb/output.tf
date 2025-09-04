output "docdb_cluster_id" {
  value = aws_docdb_cluster.this.id
}

output "docdb_instance_ids" {
  value = [for inst in aws_docdb_cluster_instance.this : inst.id]
}
