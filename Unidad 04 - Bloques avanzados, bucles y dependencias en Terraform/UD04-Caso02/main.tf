# Especificamos que usaremos el provider "docker" (el oficial de Kreuzwerker)
terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

# Activamos el provider docker local
provider "docker" {}

# Creamos una red Docker para conectar todos los contenedores
resource "docker_network" "terraform_net" {
  name = "terraform-net"
}

# Usamos nombres aleatorios (tipo "curious-cat") para cada contenedor
resource "random_pet" "web_names" {
  count  = var.web_container_count
  length = 2
}

# Creamos un archivo HTML para cada contenedor, basado en una plantilla
resource "local_file" "html_files" {
  count    = var.web_container_count

  # Nombre del archivo, usando el nombre aleatorio del contenedor
  filename = "${path.module}/site_${random_pet.web_names[count.index].id}.html"

  # Contenido generado dinámicamente con variables
  content  = templatefile("${path.module}/templates/index.html.tmpl", {
    mensaje = var.html_message
    nombre  = random_pet.web_names[count.index].id
  })
}

# Nos aseguramos de tener la imagen NGINX localmente
resource "docker_image" "nginx" {
  name = var.base_image
}

# Contenedores NGINX que sirven el HTML personalizado
resource "docker_container" "web" {
  count = var.web_container_count

  name  = "nginx-${random_pet.web_names[count.index].id}"
  image = docker_image.nginx.name

  # Conectamos el contenedor a la red compartida
  networks_advanced {
    name = docker_network.terraform_net.name
  }

  # Montamos el archivo HTML generado como página principal
  volumes {
    host_path      = abspath(local_file.html_files[count.index].filename)
    container_path = "/usr/share/nginx/html/index.html"
  }

  restart = "no"  # No reiniciar automáticamente si se detiene
}

# ─────────────────────────────
# Generar el nginx.conf del proxy
# ─────────────────────────────

# Creamos una lista de líneas "server <nombre>:80;" para el bloque upstream
locals {
  backends = [
    for container in docker_container.web :
    "server ${container.name}:80;"
  ]
}

# Usamos la plantilla nginx.conf.tmpl para generar un archivo real
resource "local_file" "nginx_config" {
  filename = "${path.module}/nginx.conf"
  content  = templatefile("${path.module}/templates/nginx.conf.tmpl", {
    backends = local.backends
  })
}

# Contenedor NGINX que actúa como reverse proxy (balanceador)
resource "docker_container" "nginx_proxy" {
  name  = "nginx-proxy"
  image = docker_image.nginx.name

  # Exponemos el puerto 80 interno del contenedor como el 8888 en el host
  ports {
    internal = 80
    external = var.exposed_port
  }

  # Conectado a la misma red Docker
  networks_advanced {
    name = docker_network.terraform_net.name
  }

  # Montamos el archivo de configuración NGINX generado automáticamente
  volumes {
    host_path      = abspath(local_file.nginx_config.filename)
    container_path = "/etc/nginx/nginx.conf"
  }

  depends_on = [docker_container.web] # Nos aseguramos de que los backends existan
}
