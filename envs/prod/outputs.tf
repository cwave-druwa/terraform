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

#output "nginx_server_instance_id" {
#  description = "The ID of the Nginx instance"
#  value       = module.nginx.nginx_server_instance_id
#}

#output "bastion_server_instance_id" {
#  description = "The ID of the bastion instance"
#  value       = module.bastion.bastion_server_instance_id
#}

# 출력 (ALB의 DNS 이름)
output "alb_dns_name" {
  description = "The DNS name of the load balancer"
  value       = aws_lb.nginx_alb.dns_name
}
