output "bastion_server_instance_id" {
  description = "The ID of the bastion instance"
  value       = aws_instance.bastion_server.id
}

