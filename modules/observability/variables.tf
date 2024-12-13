variable "cluster_name" {
  type = string
}

variable "oidc_id" {
  description = "The OIDC ID extracted from the issuer URL."
  type        = string
}

variable "eks_oidc_provider_arn" {
  description = "The ARN of the IAM OIDC provider associated with the EKS cluster."
  type        = string
}

variable "cluster_certificate_authority_data" {
  description = "The base64-encoded certificate authority data for the EKS cluster."
  type        = string
}

variable "cluster_endpoint" {
  description = "The API server endpoint for the EKS cluster."
  type        = string
}
variable "aws_region" {
  type        = string
  default     = "eu-central-1"
  description = "AWS region"
}

variable "vpc_id" {
  type        = string
  description = "vpc id"
}

variable "namespace" {
  type        = string
  default     = "monitoring"
  description = "Monitoring namespace"
}

variable "monitored_account_ids" {
  description = "List of account IDs allowed to send logs"
  type        = set(string)
}

variable "loki_bucket_name" {
  type        = string
  description = "Bucket name for Loki logs"
}

variable "mimir_bucket_name" {
  type        = string
  description = "Bucket name for mimir metrics"
}

variable "lb_logs_bucket_name" {
  type        = string
  description = "Bucket name for lb logs"
}

variable "flow_logs_bucket_name" {
  type        = string
  description = "Bucket name for vpc flow logs"
}

variable "cloud_trails_bucket_name" {
  type        = string
  description = "Bucket name for cloud trail logs"
}

variable "force_bucket_destroy" {
  type        = bool
  default     = true
  description = "Force remove of a s3 bucket ignoring content"
}

variable "scrape_interval" {
  type        = number
  default     = 3
  description = "Interval for scrape the metrics"
}

variable "ebs_storage_class_name" {
  type        = string
  default     = "ebs"
  description = "EBS Storage Class Name"
}

variable "tags" {
  type        = map(string)
  description = "Tags"

  default = {
    Environment = "environment"
    Solution    = "solution"
    Version     = "version"
    Source      = "source"
    Maintainer  = "maintainer"
    Owner       = "owner"
    Monitored   = "monitored"
    Customer    = "customer"
    Scope       = "scope"
    Az          = "az"
    Usecase     = "usecase"
  }
}