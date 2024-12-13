resource "aws_iam_policy" "grafana_agent_policy" {
  name        = "grafana-agent-policy-self"
  description = "Policy for Grafana Agent"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = concat(
      [
        {
          Sid    = "VisualEditor",
          Effect = "Allow",
          Action = [
            "tag:GetResources",
            "cloudwatch:GetMetricData",
            "cloudwatch:GetMetricStatistics",
            "cloudwatch:ListMetrics",
            "shield:ListProtections",
            "apigateway:GET",
            "storagegateway:ListGateways",
            "ec2:DescribeTransitGatewayAttachments",
            "ec2:DescribeSpotFleetRequests"
          ],
          Resource = "*"
        }
      ],
      [
        for account_id in var.monitored_account_ids : {
          Effect   = "Allow",
          Action   = "sts:AssumeRole",
          Resource = "arn:aws:iam::${account_id}:role/grafana-agent-role"
        }
      ]
    )
  })
}

resource "aws_iam_role" "grafana_agent_role" {
  name = "grafana-agent-role-self"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action = "sts:AssumeRole"
      },
      {
        Effect = "Allow"
        Principal = {
          Federated = var.eks_oidc_provider_arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "grafana-agent-policy-attach" {
  role       = aws_iam_role.grafana_agent_role.name
  policy_arn = aws_iam_policy.grafana_agent_policy.arn
}

resource "kubernetes_service_account_v1" "grafana_agent_service_account" {
  for_each = var.monitored_account_ids
  metadata {
    name      = "grafana-agent-service-account-${each.value}"
    namespace = var.namespace
    annotations = {
      "eks.amazonaws.com/role-arn" = "arn:aws:iam::${each.value}:role/grafana-agent-role"
    }
  }
}

resource "helm_release" "grafana-agent" {
  name       = local.grafana_agent_name
  namespace  = var.namespace
  repository = "https://grafana.github.io/helm-charts"
  chart      = "grafana-agent"
  version    = "0.42.0"
  values     = [local.values_grafana_agent]
  depends_on = [helm_release.kube_prometheus]
}