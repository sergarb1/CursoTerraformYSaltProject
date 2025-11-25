# -------------------------------------------------------
# Configuración básica del proveedor Terraform
# Aquí definimos qué proveedor externo vamos a usar
# En este caso: Docker (usando el proveedor de kreuzwerker)
# -------------------------------------------------------
terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"  # Fuente oficial del provider Docker
      version = "~> 3.0"              # Versión compatible
    }
  }
}

# -------------------------------------------------------
# Inicializa el proveedor Docker para que Terraform
# pueda interactuar con el servicio Docker local
# -------------------------------------------------------
provider "docker" {}

# -------------------------------------------------------
# Crea una red Docker personalizada para conectar todos
# los contenedores que Terraform desplegará
# Esto permite que los contenedores se comuniquen entre sí
# -------------------------------------------------------
resource "docker_network" "terraform_net" {
  name = "terraform-net"  # Nombre visible de la red Docker
}

# -------------------------------------------------------
# Genera una lista de nombres aleatorios y únicos para los
# contenedores web usando el recurso 'random_pet'
# Esto evita colisiones y facilita el despliegue escalado
# -------------------------------------------------------
resource "random_pet" "web_names" {
  count  = var.web_container_count  # Se crea un nombre por cada contenedor
  length = 2                        # El nombre tendrá dos palabras (ej. kind-fox)
}

# -------------------------------------------------------
# Genera archivos HTML personalizados para cada contenedor
# usando plantillas dinámicas (templatefile)
# Los archivos se guardan localmente y luego se montan
# en los contenedores como contenido web
# -------------------------------------------------------
resource "local_file" "html_files" {
  count    = var.web_container_count  # Un archivo por contenedor
  filename = "${path.module}/site_${random_pet.web_names[count.index].id}.html"  # Nombre del archivo

  # Contenido dinámico basado en la plantilla 'index.html.tmpl'
  content = templatefile("${path.module}/templates/index.html.tmpl", {
    mensaje = var.html_message                                       # Texto definido por el usuario
    nombre  = random_pet.web_names[count.index].id                   # Nombre único del contenedor
  })
}

# -------------------------------------------------------
# Se asegura de que la imagen base de Docker (nginx:latest)
# esté disponible localmente. Si no está, la descarga
# -------------------------------------------------------
resource "docker_image" "nginx" {
  name = var.base_image  # Imagen definida por variable (por defecto: nginx:latest)
}

# -------------------------------------------------------
# Crea los contenedores web (Nginx) usando la imagen
# descargada previamente y configura:
# - nombres únicos
# - conexión a la red docker
# - montaje de archivos HTML
# - exposición del primer contenedor al host (opcional)
# -------------------------------------------------------
resource "docker_container" "web" {
  count = var.web_container_count  # Crea uno o varios contenedores según se indique

  # Nombre único por contenedor usando nombre aleatorio
  name  = "nginx-${random_pet.web_names[count.index].id}"
  
  # Imagen a utilizar
  image = docker_image.nginx.name

  # Conexión del contenedor a la red personalizada
  networks_advanced {
    name = docker_network.terraform_net.name
  }

  # Exposición del puerto 80 del contenedor al host (solo el primer contenedor si está activado)
  ports {
    internal = 80
    # Si publish_first_port está en true y es el primer contenedor (index 0), lo expone
    # Si no, deja el valor en 0 (no expone)
    external = var.publish_first_port && count.index == 0 ? var.exposed_port : 0
  }

  # Montaje del archivo HTML generado en el contenedor
  volumes {
    host_path      = abspath(local_file.html_files[count.index].filename)
    container_path = "/usr/share/nginx/html/index.html"  # Ruta donde NGINX lo leerá por defecto
  }

  # Opcional: evita reinicio automático
  restart = "no"
}