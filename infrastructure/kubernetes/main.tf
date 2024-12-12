module "vpc" {
  source   = "../../modules/aws-vpc"
  vpc_cidr = var.vpc_cidr
  vpc_name = var.vpc_name
}

module "eks" {
  source              = "../../modules/aws-eks"
  cluster_name        = var.cluster_name
  vpc_id              = module.vpc.vpc_id
  vpc_intra_subnets   = module.vpc.intra_subnets
  vpc_private_subnets = module.vpc.private_subnets
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
}