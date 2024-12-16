resource "aws_iam_policy" "grafana_agent_policy" {
  name        = "grafana-agent-policy"
  description = "Policy for Grafana Agent"

  policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Sid : "VisualEditor",
        Effect : "Allow",
        Action : [
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
        Resource : "*"
      }
    ]

  })
}

resource "aws_iam_role" "grafana_agent_role" {
  name = "grafana-agent-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${var.central_observability_account}:root"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "grafana-agent-policy-attach" {
  role       = aws_iam_role.grafana_agent_role.name
  policy_arn = aws_iam_policy.grafana_agent_policy.arn
}
