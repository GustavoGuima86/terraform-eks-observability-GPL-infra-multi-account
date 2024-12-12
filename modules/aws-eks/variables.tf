variable "cluster_name" {
  type        = string
  description = "Eks cluster name"
}

variable "vpc_private_subnets" {
  type        = list(string)
  description = "Private subnet"
}

variable "vpc_intra_subnets" {
  type        = list(string)
  description = "Intra Subnet"
}

variable "vpc_id" {
  type        = string
  description = "Vpc Id"
}