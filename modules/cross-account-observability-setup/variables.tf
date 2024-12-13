variable "aws_region" {
  type        = string
  default     = "eu-central-1"
  description = "Region to deploy backend"
}

variable "log_groups" {
  type        = set(string)
  description = "List of log groups to subscribe to Promtail"
}

variable "central_observability_account" {
  type        = string
  description = "Central observability account where the logs are sent to."
}

variable "cloud_trail_central_bucket" {
  type        = string
  description = "Central bucket where Cloud Trail sends the logs"
}

variable "flow_logs_central_bucket" {
  type        = string
  description = "Central bucket where VPC Flow Logs sends the logs"
}