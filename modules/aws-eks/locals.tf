# OIDC_ID is a requirement to Observability module
locals {
  oidc_url = data.aws_eks_cluster.example.identity[0].oidc[0].issuer
  oidc_id  = regex("id/([A-Fa-f0-9-]+)$", local.oidc_url)[0]
}