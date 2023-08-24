### Tagging ###
variable "environment" {
  description = "Stage, e.g. 'production', 'staging', 'dev', or 'test'"
}

variable "part_of" {
  description = "The name of the overarching project"
}

variable "name" {
  description = "The sub-name or branded name of the service"
}

variable "component" {
  description = "The specific functional service of the element"
}

variable "orchestrator" {
  description = "The software or process that orchestrated the resource"
  default     = "terraform"
}

variable "repository" {
  description = "Full canonical url of repo where source code is hosted"
}

variable "tags" {
  type        = map(any)
  description = "Additional tags to add to all resources"
  default     = {}
}
