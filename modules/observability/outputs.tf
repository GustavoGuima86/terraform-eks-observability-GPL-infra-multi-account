output "loki_url" {
  value = "http://${kubernetes_ingress_v1.loki_ingress.status.0.load_balancer.0.ingress.0.hostname}/loki/api/v1/push"
}