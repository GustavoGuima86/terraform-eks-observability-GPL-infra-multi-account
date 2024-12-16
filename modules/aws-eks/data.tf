data "aws_region" "current" {}

data "aws_eks_cluster" "cluster_data" {
  name       = module.eks.cluster_name
  depends_on = [module.eks, module.ebs_csi, module.eks_blueprints_kubernetes_addons]
}