output "ecs_cluster_id" {
  description = "ECS Cluster ID"
  value       = aws_ecs_cluster.cluster.id
}

output "ecs_nginx_create_task_arn" {
  description = "Task that create nginx on ecs"
  value       = aws_ecs_task_definition.nginx.arn
}

