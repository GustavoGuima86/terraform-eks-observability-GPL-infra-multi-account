resource "aws_flow_log" "vpc_flow_logs" {
  for_each             = toset(data.aws_vpcs.all_vpcs.ids) // getting all VPCs in the current account, please fell free to change it for wanted VPCs
  log_destination      = "arn:aws:s3:::${var.flow_logs_central_bucket}"
  log_destination_type = "s3"
  traffic_type         = "ALL" # Options: ACCEPT, REJECT, ALL
  vpc_id               = each.value
}