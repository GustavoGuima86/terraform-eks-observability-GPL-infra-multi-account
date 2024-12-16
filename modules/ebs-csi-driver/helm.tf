resource "helm_release" "ebs_csi_driver" {
  name             = "ebs-csi-driver"
  namespace        = var.namespace
  create_namespace = "true"
  repository       = "https://kubernetes-sigs.github.io/aws-ebs-csi-driver"
  chart            = "aws-ebs-csi-driver"
  version          = "2.18.0"

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.ebs_csi_iam_role.arn
  }

  set {
    name  = "controller.region"
    value = var.aws_region
  }
}