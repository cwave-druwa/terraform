output "bastion_server_instance_id" {
  description = "The ID of the bastion instance"
  value       = aws_instance.bastion_server.id
}

output "key_pair_name" {
  description = "The name of the SSH key pair used by the Bastion host"
  value       = aws_key_pair.bastion_key_pair.key_name
}

output "key_pair_arn" {
  description = "The ARN of the SSH key pair"
  value       = aws_key_pair.bastion_key_pair.arn
}
