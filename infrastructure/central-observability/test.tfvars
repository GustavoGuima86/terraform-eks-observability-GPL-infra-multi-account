region                   = "eu-central-1"
cluster_name             = "gustavo-cluster-1"
vpc_cidr                 = "10.0.0.0/16"
vpc_name                 = "eks-vpc"
observability_namespace  = "monitoring"
loki_bucket_name         = "gustavo-loki-bucket"
mimir_bucket_name        = "gustavo-mimir-bucket"
lb_logs_bucket_name      = "gustavo-lb-bucket"
flow_logs_bucket_name    = "gustavo-flow-logs-bucket"
cloud_trails_bucket_name = "gustavo-cloud-trail-bucket"

alert_email = "email@email.email"

monitored_accounts = ["277707138630"]