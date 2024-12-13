resource "aws_s3_bucket" "lb_s3_bucket" {
  bucket        = var.lb_logs_bucket_name
  force_destroy = var.force_bucket_destroy

  tags = var.tags
}

resource "aws_s3_bucket_policy" "lb_s3_bucket_policy" {
  bucket = aws_s3_bucket.lb_s3_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowALBAccessFromCurrentAccount"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::054676820928:root" // ID reference to alb region frankfurt, it's not an account id
        }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.lb_s3_bucket.arn}/*"
      },
      {
        Sid    = "AllowLogDelivery"
        Effect = "Allow"
        Principal = {
          Service : "delivery.logs.amazonaws.com"
        }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.lb_s3_bucket.arn}/*"
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = var.monitored_account_ids
          }
        }
      },
      {
        Effect : "Allow",
        Principal : {
          AWS : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/lambda_promtail"
        },
        Action : "s3:GetObject",
        Resource : ["${aws_s3_bucket.lb_s3_bucket.arn}/*"]
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = var.monitored_account_ids
          }
        }
      }
    ]
  })
}


resource "aws_s3_bucket" "vpc_flow_s3_bucket" {
  bucket        = var.flow_logs_bucket_name
  force_destroy = var.force_bucket_destroy

  tags = var.tags
}

resource "aws_s3_bucket_policy" "lb_flow_s3_bucket_policy" {
  bucket = aws_s3_bucket.vpc_flow_s3_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect : "Allow",
        Principal : {
          AWS : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/lambda_promtail"
        },
        Action : "s3:GetObject",
        Resource : ["${aws_s3_bucket.vpc_flow_s3_bucket.arn}/*"]
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = var.monitored_account_ids
          }
        }
      },
      {
        Sid    = "AllowVPCLFlowLogs",
        Effect = "Allow",
        Principal = {
          Service = "delivery.logs.amazonaws.com"
        },
        Action   = "s3:PutObject",
        Resource = "${aws_s3_bucket.vpc_flow_s3_bucket.arn}/*",
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = var.monitored_account_ids
          }
        }
      },
      {
        Sid    = "AllowBucketOwnership",
        Effect = "Allow",
        Principal = {
          Service = "delivery.logs.amazonaws.com"
        },
        Action = [
          "s3:GetBucketAcl",
          "s3:ListBucket"
        ],
        Resource = aws_s3_bucket.vpc_flow_s3_bucket.arn,
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = var.monitored_account_ids
          }
        }
      }
    ]
  })
}

resource "aws_s3_bucket" "cloud_trail_s3_bucket" {
  bucket        = var.cloud_trails_bucket_name
  force_destroy = var.force_bucket_destroy

  tags = var.tags
}

resource "aws_s3_bucket_policy" "cloud_trail_s3_bucket_policy" {
  bucket = aws_s3_bucket.cloud_trail_s3_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect : "Allow",
        Principal : {
          AWS : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/lambda_promtail"
        },
        Action : "s3:GetObject",
        Resource : ["${aws_s3_bucket.cloud_trail_s3_bucket.arn}/*"]
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = var.monitored_account_ids
          }
        }
      },
      {
        Sid    = "AllowCloudTrailWrite",
        Effect = "Allow",
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        },
        Action   = "s3:PutObject",
        Resource = "${aws_s3_bucket.cloud_trail_s3_bucket.arn}/AWSLogs/*",
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = var.monitored_account_ids
          }
        }
      },
      {
        Sid    = "AllowBucketOwnership",
        Effect = "Allow",
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        },
        Action   = "s3:GetBucketAcl",
        Resource = aws_s3_bucket.cloud_trail_s3_bucket.arn
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = var.monitored_account_ids
          }
        }
      }
    ]
  })
}