# URL para acceder a WordPress desde el navegador
output "wordpress_url" {
  description = "URL de acceso a WordPress"
  value       = "http://localhost:${var.wordpress_port}"
}

# URL para acceder a phpMyAdmin desde el navegador
output "phpmyadmin_url" {
  description = "URL de acceso a phpMyAdmin"
  value       = "http://localhost:${var.phpmyadmin_port}"
}

# Información útil para conectarse a la base de datos manualmente
output "database_info" {
  description = "Información de la base de datos creada"
  value = {
    database = var.mysql_database
    user     = "root"
    password = var.mysql_root_password
  }
}
