variable "env" {
  description = "Environment name (e.g., prod, dev)"
  type        = string
  default     = "env"
}

variable "region" {
  description = "Region name (e.g., kr, dk)"
  type        = string
  default     = "region"
}

variable "region_id" {
  description = "Region id (e.g., ap-northeast-1, ap-northeast-2)"
  type        = string
  default     = "region"
}

variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "a_public_subnet_01_cidr_block" {
  description = "CIDR block for the AZ a public subnet"
  type        = string
}

variable "a_private_subnet_01_cidr_block" {
  description = "CIDR block for the AZ a first private subnet"
  type        = string
}

variable "a_private_subnet_02_cidr_block" {
  description = "CIDR block for the AZ a second private subnet"
  type        = string
}

variable "a_private_subnet_03_cidr_block" {
  description = "CIDR block for the AZ a third private subnet"
  type        = string
}

variable "tags" {
  description = "Tags to assign to resources"
  type        = map(string)
  default     = {}
}
