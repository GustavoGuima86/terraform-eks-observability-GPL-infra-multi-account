resource "aws_s3_bucket" "mimir_bucket_chunk" {
  bucket        = local.bucket_mimir_chunk
  force_destroy = var.force_bucket_destroy
}

resource "aws_s3_bucket" "mimir_bucket_ruler" {
  bucket        = local.bucket_mimir_ruler
  force_destroy = var.force_bucket_destroy
}

resource "aws_s3_bucket" "mimir_bucket_alert" {
  bucket        = local.bucket_mimir_alert
  force_destroy = var.force_bucket_destroy
}

resource "aws_s3_bucket_lifecycle_configuration" "lifecycle_mimir_chunk_bucket" {
  bucket = aws_s3_bucket.mimir_bucket_chunk.id

  rule {
    id     = "delete-objects-older-than-7-days"
    status = "Enabled"

    expiration {
      days = 30
    }
  }
}

resource "aws_iam_policy" "mimir_s3_policy" {
  name        = "mimir-s3-policy"
  description = "Policy for Loki to access specific S3 buckets"

  policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Sid : "VisualEditor",
        Effect : "Allow",
        Action : [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:DeleteObject",
          "s3:PutObjectAcl",
          "s3:GetBucketLocation"
        ],
        Resource : [
          "arn:aws:s3:::${local.bucket_mimir_chunk}",
          "arn:aws:s3:::${local.bucket_mimir_chunk}/*",
          "arn:aws:s3:::${local.bucket_mimir_alert}",
          "arn:aws:s3:::${local.bucket_mimir_alert}/*",
          "arn:aws:s3:::${local.bucket_mimir_ruler}",
          "arn:aws:s3:::${local.bucket_mimir_ruler}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role" "mimir_s3_role" {
  name = "mimir-s3-role"

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
            "oidc.eks.${local.region}.amazonaws.com/id/${var.oidc_id}:sub" = "system:serviceaccount:${var.namespace}:${local.sa_mimir_name}",
            "oidc.eks.${local.region}.amazonaws.com/id/${var.oidc_id}:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "mimir-policy-attach" {
  role       = aws_iam_role.mimir_s3_role.name
  policy_arn = aws_iam_policy.mimir_s3_policy.arn
}


resource "helm_release" "mimir" {
  name       = local.mimir_name
  namespace  = var.namespace
  repository = "https://grafana.github.io/helm-charts"
  chart      = "mimir-distributed"
  version    = "5.5.1"
  values     = [local.values_mimir]
  depends_on = [helm_release.grafana-agent]
}

resource "aws_security_group" "mimir_sg" {
  name        = "mimir-alb-sg"
  description = "Security group for the ALB managing the Mimir ingress"
  vpc_id      = var.vpc_id

  tags = var.tags

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow ALB to forward traffic to backend pods on port 8080
  ingress {
    from_port = 8080
    to_port   = 8080
    protocol  = "TCP"
    self      = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}