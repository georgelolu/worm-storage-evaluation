variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "worm-storage-evaluation"
}

variable "retention_days" {
  description = "Default Governance retention period"
  type        = number
  default     = 1
}
