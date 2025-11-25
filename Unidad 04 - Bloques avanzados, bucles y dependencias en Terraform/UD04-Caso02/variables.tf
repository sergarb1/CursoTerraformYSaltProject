# Número de contenedores NGINX backend que se desplegarán
variable "web_container_count" {
  description = "Número de contenedores web (nginx) a desplegar"
  type        = number
  default     = 3
}

# Mensaje HTML personalizado que verá el usuario en cada contenedor
variable "html_message" {
  description = "Mensaje HTML que se mostrará en cada contenedor"
  type        = string
  default     = "¡Hola desde Terraform + Docker!"
}

# Imagen base de NGINX. Puede ser "nginx:latest", "nginx:alpine", etc.
variable "base_image" {
  description = "Imagen de contenedor base (debe tener nginx)"
  type        = string
  default     = "nginx:latest"
}

# Puerto local donde se expondrá el balanceador de carga
variable "exposed_port" {
  description = "Puerto local donde se expone el balanceador"
  type        = number
  default     = 8888
}
