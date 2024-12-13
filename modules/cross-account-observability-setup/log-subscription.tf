resource "aws_cloudwatch_log_subscription_filter" "send_to_lambda" {
  for_each        = var.log_groups
  name            = "SendLogsToPromtail"
  log_group_name  = each.value
  destination_arn = "arn:aws:logs:${var.aws_region}:${var.central_observability_account}:destination:CrossAccountDestination"
  filter_pattern  = ""
}
