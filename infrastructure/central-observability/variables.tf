variable "region" {
  type    = string
  default = "eu-central-1"
}

variable "cluster_name" {
  type    = string
  default = "cluster"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR of the VPC"
  default     = "10.0.0.0/16"
}

variable "vpc_name" {
  type        = string
  default     = "eks-vpc"
  description = "The name of the VPC"
}

variable "observability_namespace" {
  type        = string
  default     = "monitoring"
  description = "The namespace to use for Kubernetes resources within the EKS cluster."
}

variable "loki_bucket_name" {
  type    = string
  default = "loki-bucket"
}

variable "mimir_bucket_name" {
  type    = string
  default = "mimir-bucket"
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

variable "monitored_accounts" {
  type        = list(string)
  description = "Monitored account to be watched"
}

variable "alert_email" {
  type        = string
  description = "Email to send alerts"
}
