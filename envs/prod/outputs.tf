output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.network.vpc_id
}

output "a_public_subnet_01_id" {
  description = "The ID of the public subnet"
  value       = module.network.a_public_subnet_01_id
}

output "a_private_subnet_01_id" {
  description = "The ID of the first private subnet"
  value       = module.network.a_private_subnet_01_id
}

output "a_private_subnet_02_id" {
  description = "The ID of the second private subnet"
  value       = module.network.a_private_subnet_02_id
}

output "c_public_subnet_01_id" {
  description = "The ID of the public subnet"
  value       = module.network.c_public_subnet_01_id
}

output "c_private_subnet_01_id" {
  description = "The ID of the first private subnet"
  value       = module.network.c_private_subnet_01_id
}

output "c_private_subnet_02_id" {
  description = "The ID of the second private subnet"
  value       = module.network.c_private_subnet_02_id
}

output "nginx_server_instance_id" {
  description = "The ID of the Nginx instance"
  value       = module.nginx.nginx_server_instance_id
}

output "bastion_server_instance_id" {
  description = "The ID of the bastion instance"
  value       = module.bastion.bastion_server_instance_id
}

output "private_key_pem" {
  value     = module.bastion.private_key_pem
  sensitive = true
}