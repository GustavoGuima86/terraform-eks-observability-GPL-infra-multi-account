data "aws_region" "current" {}

# Retrieve the EKS cluster details
data "aws_eks_cluster" "example" {
  name       = module.eks.cluster_name
  depends_on = [module.eks, module.ebs_csi, module.eks_blueprints_kubernetes_addons]
}

# Retrieve the OIDC provider
data "aws_eks_cluster_auth" "example" {
  name = module.eks.cluster_name
}
