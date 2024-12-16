variable "region" {
  type    = string
  default = "eu-central-1"
}

variable "flow_logs_bucket_name" {
  type        = string
  description = "Bucket name for vpc flow logs"
}

variable "cloud_trails_bucket_name" {
  type        = string
  description = "Bucket name for cloud trail logs"
}

variable "gustavo_account_2" {
  type        = string
  description = "Account to be collected cross account observability data"
  default     = "277707138630"
}