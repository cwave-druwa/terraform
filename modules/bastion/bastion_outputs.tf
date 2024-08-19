output "bastion_server_instance_id" {
  description = "The ID of the bastion instance"
  value       = aws_instance.bastion_server.id
}

output "private_key_pem" {
  value     = tls_private_key.bastion.private_key_pem
  sensitive = true
}

output "public_key_openssh" {
  value = tls_private_key.bastion.public_key_openssh
}
