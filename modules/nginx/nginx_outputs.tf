output "nginx_server_instance_id" {
  description = "The ID of the Nginx instance"
  value       = aws_instance.nginx_server.id
}