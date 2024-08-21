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
variable "subnets" {
  description = "List of subnets where ECS services will be deployed"
  type        = list(string)
}

variable "security_groups" {
  description = "Security groups to attach to ECS services"
  type        = list(string)
}

variable "desired_count" {
  description = "Desired number of ECS tasks"
  type        = number
  default     = 1
}

variable "task_execution_role_arn" {
  description = "IAM Role ARN for ECS task execution"
  type        = string
}

variable "alb_target_group_arn" {
  description = "ALB Target Group ARN"
  type        = string
}
