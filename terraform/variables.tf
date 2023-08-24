variable "region" {
  description = "AWS Region to deploy to"
  type        = string
}

variable "environment" {
  description = "Stage, e.g. 'production', 'staging'"
  type        = string
  default     = "demo"
}