output "cluster_id" {
  value       = aws_ecs_cluster.main.id
  description = "ID of ecs cluster"
}

output "cluster_name" {
  value       = aws_ecs_cluster.main.name
  description = "Name of ecs cluster"
}

