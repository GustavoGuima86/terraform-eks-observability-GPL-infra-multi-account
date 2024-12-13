locals {

  bucket_loki_chunk = "${var.loki_bucket_name}-chunk"
  bucket_loki_ruler = "${var.loki_bucket_name}-ruler"

  bucket_mimir_chunk = "${var.mimir_bucket_name}-chunk"
  bucket_mimir_ruler = "${var.mimir_bucket_name}-ruler"
  bucket_mimir_alert = "${var.mimir_bucket_name}-alert"

  sa_loki_name       = "loki-sa"
  sa_mimir_name      = "mimir-sa"
  mimir_name         = "mimir"
  kube_prometheus    = "kube-prometheus"
  grafana_agent_name = "grafana-agent"

  region = data.aws_region.current.name

  values_loki = templatefile("${path.module}/values/values-loki.yaml.tpl", {
    region                 = local.region
    bucket_chunk           = local.bucket_loki_chunk
    bucket_ruler           = local.bucket_loki_ruler
    role_arn               = aws_iam_role.loki_s3_role.arn
    sa_loki_name           = local.sa_loki_name
    ebs_storage_class_name = var.ebs_storage_class_name
  })

  values_mimir = templatefile("${path.module}/values/values-mimir.yaml.tpl", {
    region          = local.region
    bucket_chunk    = local.bucket_mimir_chunk
    bucket_ruler    = local.bucket_mimir_ruler
    bucket_alert    = local.bucket_mimir_alert
    role_arn        = aws_iam_role.mimir_s3_role.arn
    sa_mimir_name   = local.sa_mimir_name
    kube_prometheus = local.kube_prometheus
  })

  values_grafana = templatefile("${path.module}/values/values-grafana.yaml.tpl", {
    adminPassword = aws_ssm_parameter.password_grafana.value
    mimir         = local.mimir_name
    namespace     = var.namespace
  })

  values_grafana_agent = templatefile("${path.module}/values/grafana-agent.yaml.tpl", {
    exporter_name       = local.grafana_agent_name
    role_arn            = aws_iam_role.grafana_agent_role.arn
    account_id_list     = var.monitored_account_ids
    mimir_load_balancer = "http://${local.mimir_name}-nginx.${var.namespace}.svc:80/api/v1/push"
    region              = local.region
    scrape_interval     = var.scrape_interval
  })
}