# resource "aws_flow_log" "vpc_flow_logs" {
#   for_each             = toset(data.aws_vpcs.all_vpcs.ids)
#   log_destination      = aws_s3_bucket.vpc_flow_s3_bucket.arn
#   log_destination_type = "s3"
#   traffic_type         = "ALL" # Options: ACCEPT, REJECT, ALL
#   vpc_id               = each.value
# }