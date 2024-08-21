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

variable "tags" {
  description = "Tags to assign to resources"
  type        = map(string)
  default     = {}
}
