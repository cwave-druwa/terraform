variable "env" {
  description = "Environment name (e.g., prod, dev)"
  type        = string
  default     = "env"
}

variable "ami_id" {
  description = "Instance AMI id"
  type        = string
}

variable "instance_name" {
  description = "EC2 instance name"
  type        = string
  default     = "server"
}

variable "instance_type" {
  description = "EC2 instance type (e.g., t2.micro, t3.large)"
  type        = string
  default     = "t2.micro"
}

variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "subnet_id" {
  description = "The ID of the subnet"
  type        = string
}

variable "tags" {
  description = "Tags to assign to resources"
  type        = map(string)
  default     = {}
}

variable "key_name" {
  description = "Key-pair name"
  type        = string
}

variable "user_data" {
  description = "User data script for EC2 instance"
  type        = string
  default     = ""
}