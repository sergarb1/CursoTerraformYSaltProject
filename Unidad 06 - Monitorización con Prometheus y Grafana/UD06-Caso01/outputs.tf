output "wordpress_url" {
  value       = "http://localhost:${var.wordpress_port}"
  description = "Acceso a WordPress"
}

output "prometheus_url" {
  value       = "http://localhost:${var.prometheus_port}"
  description = "Panel Prometheus"
}

output "grafana_url" {
  value       = "http://localhost:${var.grafana_port}"
  description = "Panel Grafana"
}
