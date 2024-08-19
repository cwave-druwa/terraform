output "bastion_server_instance_id" {
  description = "The ID of the bastion instance"
  value       = aws_instance.bastion_server.id
}

output "bastion_security_group_id" {
  description =
  value       = aws_security_group.bastion_sg.id
}