resource "aws_s3_bucket" "loki_bucket_chunk" {
  bucket        = local.bucket_loki_chunk
  force_destroy = var.force_bucket_destroy

}

resource "aws_s3_bucket" "loki_bucket_ruler" {
  bucket        = local.bucket_loki_ruler
  force_destroy = var.force_bucket_destroy
}

resource "aws_s3_bucket_lifecycle_configuration" "lifecycle_loki_chunk_bucket" {
  bucket = aws_s3_bucket.loki_bucket_chunk.id

  rule {
    id     = "delete-objects-older-than-7-days"
    status = "Enabled"

    expiration {
      days = 30
    }
  }
}

resource "aws_iam_policy" "loki_s3_policy" {
  name        = "loki-s3-policy"
  description = "Policy for Loki to access specific S3 buckets"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "VisualEditor",
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:GetObject",
        "s3:ListBucket",
        "s3:DeleteObject"
      ],
      "Resource": [
        "arn:aws:s3:::${local.bucket_loki_chunk}",
        "arn:aws:s3:::${local.bucket_loki_chunk}/*",
        "arn:aws:s3:::${local.bucket_loki_ruler}",
        "arn:aws:s3:::${local.bucket_loki_ruler}/*"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_role" "loki_s3_role" {
  name = "loki-s3-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = var.eks_oidc_provider_arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "oidc.eks.${local.region}.amazonaws.com/id/${var.oidc_id}:sub" = "system:serviceaccount:${var.namespace}:${local.sa_loki_name}",
            "oidc.eks.${local.region}.amazonaws.com/id/${var.oidc_id}:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "loki-policy-attach" {
  role       = aws_iam_role.loki_s3_role.name
  policy_arn = aws_iam_policy.loki_s3_policy.arn
}

resource "helm_release" "loki" {
  name       = "loki"
  namespace  = var.namespace
  repository = "https://grafana.github.io/helm-charts"
  chart      = "loki"
  version    = "6.19.0"
  values     = [local.values_loki]
  depends_on = [kubectl_manifest.namespace]
}

resource "helm_release" "promtail" {
  name       = "promtail"
  namespace  = var.namespace
  repository = "https://grafana.github.io/helm-charts"
  chart      = "promtail"
  version    = "6.15.3"

  values = [
    file("${path.module}/values/values-promtail.yaml")
  ]
  depends_on = [helm_release.loki]
}

resource "aws_security_group" "loki_sg" {
  name        = "loki-alb-sg"
  description = "Security group for the ALB managing the Loki ingress"
  vpc_id      = var.vpc_id

  tags = var.tags

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "kubernetes_ingress_v1" "loki_ingress" {
  wait_for_load_balancer = true
  metadata {
    name      = "loki"
    namespace = var.namespace
    annotations = {
      "alb.ingress.kubernetes.io/listen-ports"     = "[{\"HTTP\":80}]"
      "alb.ingress.kubernetes.io/scheme"           = "internal"
      "alb.ingress.kubernetes.io/target-type"      = "ip"
      "alb.ingress.kubernetes.io/healthcheck-path" = "/api/health"
      "alb.ingress.kubernetes.io/security-groups"  = aws_security_group.loki_sg.id
      "alb.ingress.kubernetes.io/manage-backend-security-group-rules" : "true"
      "alb.ingress.kubernetes.io/load-balancer-attributes" = "access_logs.s3.enabled=true,access_logs.s3.bucket=${aws_s3_bucket.lb_s3_bucket.bucket},access_logs.s3.prefix=alb-logs-loki"
    }
  }

  spec {
    ingress_class_name = "alb"

    default_backend {
      service {
        name = "loki-gateway"
        port {
          number = 80
        }
      }
    }
  }
  depends_on = [aws_s3_bucket.lb_s3_bucket, helm_release.loki]
}
