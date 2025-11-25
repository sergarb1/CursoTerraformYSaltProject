# Contraseña root para MySQL
variable "mysql_root_password" {
  description = "Contraseña root de MySQL"
  type        = string
  default     = "supersecurepass"
}

# Nombre de la base de datos donde WordPress guardará su contenido
variable "mysql_database" {
  description = "Nombre de la base de datos de WordPress"
  type        = string
  default     = "wordpress"
}

# Puerto en el que se expone el sitio WordPress (en tu máquina local)
variable "wordpress_port" {
  description = "Puerto local para WordPress"
  type        = number
  default     = 8080
}

# Puerto para acceder a phpMyAdmin desde el navegador
variable "phpmyadmin_port" {
  description = "Puerto local para phpMyAdmin"
  type        = number
  default     = 8081
}

# Imagen utilizada para el contenedor MySQL (se puede cambiar fácilmente)
variable "mysql_image" {
  description = "Imagen Docker de MySQL"
  type        = string
  default     = "mysql:5.7"
}

# Imagen utilizada para el contenedor WordPress
variable "wordpress_image" {
  description = "Imagen Docker de WordPress"
  type        = string
  default     = "wordpress:latest"
}

# Imagen utilizada para el contenedor phpMyAdmin
variable "phpmyadmin_image" {
  description = "Imagen Docker de phpMyAdmin"
  type        = string
  default     = "phpmyadmin:latest"
}
