variable "mysql_root_password" {
  description = "Contraseña root de MySQL"
  default     = "rootpass"
}

variable "mysql_database" {
  description = "Base de datos de WordPress"
  default     = "wpdb"
}

variable "mysql_user" {
  description = "Usuario MySQL"
  default     = "wpuser"
}

variable "mysql_password" {
  description = "Contraseña MySQL"
  default     = "wppass"
}

variable "wordpress_port" {
  description = "Puerto de WordPress"
  default     = 8080
}

variable "prometheus_port" {
  description = "Puerto de Prometheus"
  default     = 9090
}

variable "grafana_port" {
  description = "Puerto de Grafana"
  default     = 3000
}

variable "node_exporter_port" {
  description = "Puerto de Node Exporter"
  default     = 9100
}

variable "grafana_user" {
  description = "Usuario admin Grafana"
  default     = "admin"
}

variable "grafana_password" {
  description = "Contraseña admin Grafana"
  default     = "admin"
}
