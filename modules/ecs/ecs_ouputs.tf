output "ecs_cluster_id" {
  description = "ECS Cluster ID"
  value       = aws_ecs_cluster.cluster.id
}

output "ecs_service_name" {
  description = "ECS Service Name"
  value       = aws_ecs_service.nginx_service.name
}
