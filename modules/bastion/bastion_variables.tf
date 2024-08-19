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

variable "region_id" {
  description = "Region id (e.g., ap-northeast-1, ap-northeast-2)"
  type        = string
  default     = "region"
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



