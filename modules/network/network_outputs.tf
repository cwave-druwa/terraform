output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main.id
}

output "a_public_subnet_01_id" {
  description = "The ID of the AZ a public subnet"
  value       = aws_subnet.a_public_01.id
}


output "a_private_subnet_01_id" {
  description = "The ID of the AZ a first private subnet"
  value       = aws_subnet.a_private_01.id
}


output "a_private_subnet_02_id" {
  description = "The ID of the AZ a second private subnet"
  value       = aws_subnet.a_private_02.id
}

output "c_public_subnet_01_id" {
  description = "The ID of the AZ c public subnet"
  value       = aws_subnet.c_public_01.id
}


output "c_private_subnet_01_id" {
  description = "The ID of the AZ c first private subnet"
  value       = aws_subnet.c_private_01.id
}

output "c_private_subnet_02_id" {
  description = "The ID of the AZ c second private subnet"
  value       = aws_subnet.c_private_02.id
}

#output "a_private_subnet_03_id" {
#  description = "The ID of the AZ a third private subnet"
#  value       = aws_subnet.a_private_03.id
#}

