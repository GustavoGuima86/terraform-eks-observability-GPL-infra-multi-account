# data "aws_vpc" "vpc" {
#   filter {
#     name   = "tag:Name"
#     values = [var.eks_vpc]
#   }
# }
#
# data "aws_subnets" "private" {
#   filter {
#     name   = "vpc-id"
#     values = [data.aws_vpc.vpc.id]
#   }
#
#   # define filter to get specific subnets if needed
#   # tags = {
#   #   Tier = "Private"
#   # }
# }

data "aws_caller_identity" "current" {}