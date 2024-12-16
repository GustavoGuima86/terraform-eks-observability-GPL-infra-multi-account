module "cross-account-config-self_account" {
  source                        = "../../modules/cross-account-observability-setup"
  central_observability_account = data.aws_caller_identity.current.id
  cloud_trail_central_bucket    = var.cloud_trails_bucket_name
  flow_logs_central_bucket      = var.flow_logs_bucket_name
  log_groups                    = []

  providers = {
    aws = aws.main
  }
}

module "cross-account-config-gustavo-2" {
  source                        = "../../modules/cross-account-observability-setup"
  central_observability_account = data.aws_caller_identity.current.id
  cloud_trail_central_bucket    = var.cloud_trails_bucket_name
  flow_logs_central_bucket      = var.flow_logs_bucket_name
  log_groups                    = ["/aws/lambda/testPrint"]

  providers = {
    aws = aws.gustavo_account_2
  }
}