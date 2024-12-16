locals {
  monitored_accounts = concat(var.monitored_accounts, [data.aws_caller_identity.current.id])
}