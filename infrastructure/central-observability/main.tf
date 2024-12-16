module "vpc" {
  source   = "../../modules/aws-vpc"
  vpc_cidr = var.vpc_cidr
  vpc_name = var.vpc_name

  providers = { aws = aws.main }
}

module "eks" {
  source              = "../../modules/aws-eks"
  cluster_name        = var.cluster_name
  vpc_id              = module.vpc.vpc_id
  vpc_intra_subnets   = module.vpc.intra_subnets
  vpc_private_subnets = module.vpc.private_subnets

  providers = { aws = aws.main }
}

module "observability" {
  source                             = "../../modules/observability"
  namespace                          = var.observability_namespace
  loki_bucket_name                   = var.loki_bucket_name
  mimir_bucket_name                  = var.mimir_bucket_name
  oidc_id                            = module.eks.oidc_id                            # Required by Roles to access S3 from EKS using RBAC / Service account
  cluster_name                       = module.eks.cluster_name                       # Required by providers provider
  cluster_endpoint                   = module.eks.cluster_endpoint                   # Required by providers provider
  eks_oidc_provider_arn              = module.eks.eks_oidc_provider_arn              # Required by Roles to access S3 from EKS using RBAC / Service account
  cluster_certificate_authority_data = module.eks.cluster_certificate_authority_data # Required by providers
  monitored_account_ids              = local.monitored_accounts
  cloud_trails_bucket_name           = var.cloud_trails_bucket_name
  flow_logs_bucket_name              = var.flow_logs_bucket_name
  lb_logs_bucket_name                = var.lb_logs_bucket_name
  vpc_id                             = module.vpc.vpc_id

  providers = { aws = aws.main }
}

module "promtail-lambda" {
  source                  = "../../modules/promtail-lambda"
  email_alert             = var.alert_email
  monitoring_accounts_id  = local.monitored_accounts
  security_group          = module.eks.cluster_sg
  loki_url                = module.observability.loki_url
  vpc_private_subnets_ids = module.vpc.private_subnets
  log_group_names         = ["/aws/lambda/print"]

  providers = { aws = aws.main }
}

