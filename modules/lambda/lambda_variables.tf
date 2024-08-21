variable "function_name" {
  description = "Lambda function name"
  type        = string
}

variable "runtime" {
  description = "Lambda runtime environment"
  type        = string
  default     = "python3.8"
}
