# -------------------------------------------------------
# Número de contenedores web que queremos desplegar
# Puedes aumentar este número para escalar horizontalmente
# (es decir, lanzar más servidores NGINX en paralelo)
# -------------------------------------------------------
variable "web_container_count" {
  description = "Número de contenedores web (nginx) a desplegar"
  type        = number
  default     = 2
}

# -------------------------------------------------------
# Mensaje que se mostrará en el archivo HTML de cada contenedor
# Este mensaje será insertado en una plantilla (templatefile)
# útil para personalizar el contenido web desde Terraform
# -------------------------------------------------------
variable "html_message" {
  description = "Mensaje HTML que se mostrará en cada contenedor"
  type        = string
  default     = "¡Hola desde Terraform + Docker!"
}

# -------------------------------------------------------
# Imagen base de Docker a utilizar. Debe tener NGINX instalado
# Por defecto usamos 'nginx:latest', pero puedes cambiarlo
# por otra versión específica como 'nginx:1.21' si lo deseas.
# -------------------------------------------------------
variable "base_image" {
  description = "Imagen de contenedor base (debe tener nginx instalado)"
  type        = string
  default     = "nginx:latest"
}

# -------------------------------------------------------
# Esta variable define si queremos exponer el primer contenedor
# al puerto local del equipo. Es útil para poder acceder a la
# web desde el navegador en 'http://localhost:PUERTO'
# -------------------------------------------------------
variable "publish_first_port" {
  description = "¿Exponer el primer contenedor localmente?"
  type        = bool
  default     = true
}

# -------------------------------------------------------
# Puerto del host local donde se expondrá el contenedor NGINX
# Solo aplica si publish_first_port = true
# Ejemplo: si es 8080, podrás acceder en http://localhost:8080
# -------------------------------------------------------
variable "exposed_port" {
  description = "Puerto en el host local para el primer contenedor"
  type        = number
  default     = 8080
}