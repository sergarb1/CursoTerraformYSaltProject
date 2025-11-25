##############################################
# 🧩 Proyecto: Laboratorio Terraform + Docker + Salt
# Despliega automáticamente un Salt Master y N Minions
# usando imágenes personalizadas basadas en Ubuntu 24.04
##############################################

# ============================================
# 🔧 1️⃣ Definición del bloque Terraform
# ============================================
terraform {
  required_providers {
    docker = {
      # Fuente oficial del provider Docker para Terraform
      source  = "kreuzwerker/docker"

      # Versión recomendada (mayor o igual a 3.0 pero menor que 4.0)
      version = "~> 3.0"
    }
  }
}

# ============================================
# 🐳 2️⃣ Proveedor Docker
# ============================================
# Permite a Terraform comunicarse con el daemon de Docker
provider "docker" {}

# ============================================
# 🕸️ 3️⃣ Creación de red interna
# ============================================
# Define una red Docker llamada "salt-net"
# donde se conectarán tanto el master como los minions.
resource "docker_network" "salt_net" {
  name = "salt-net"
}

# ============================================
# 🏗️ 4️⃣ Construcción de la imagen Salt Master
# ============================================
# Terraform construirá la imagen personalizada del master
# usando el Dockerfile que se encuentra en la carpeta ./salt-master
resource "docker_image" "salt_master_image" {
  name = "salt-master:ubuntu24"  # Nombre/tag local de la imagen

  build {
    context    = "${path.module}/salt-master"           # Ruta del contexto de build
    dockerfile = "${path.module}/salt-master/Dockerfile" # Fichero Dockerfile a usar
  }
}

# ============================================
# 🏗️ 5️⃣ Construcción de la imagen Salt Minion
# ============================================
# Igual que el master, pero con el Dockerfile de los minions
resource "docker_image" "salt_minion_image" {
  name = "salt-minion:ubuntu24"

  build {
    context    = "${path.module}/salt-minion"
    dockerfile = "${path.module}/salt-minion/Dockerfile"
  }
}

# ============================================
# 🧠 6️⃣ Creación del contenedor Salt Master
# ============================================
resource "docker_container" "salt_master" {
  name     = "salt-master"                            # Nombre del contenedor
  image    = docker_image.salt_master_image.image_id  # Imagen base (la que hemos construido)
  hostname = "salt-master"                            # Nombre de host visible en la red Docker

  # 🔗 Conectamos el contenedor a la red salt-net
  networks_advanced {
    name = docker_network.salt_net.name
  }

  # 🔓 Puertos internos/externos del master (para comunicación con los minions)
  ports {
    internal = 4505   # Publisher port
    external = 4505
  }

  ports {
    internal = 4506   # Returner port
    external = 4506
  }

  # 📂 Montamos el directorio local "salt-states" en /srv/salt
  # Esto permite al master acceder a los ficheros .sls y plantillas.
  mounts {
    type   = "bind"                                     # Tipo de montaje: bind mount
    source = abspath("${path.module}/salt-states")      # Ruta absoluta al directorio local
    target = "/srv/salt"                                # Ruta dentro del contenedor
  }

  # 🧾 Comando que ejecutará el master al iniciar
  # Modo verbose (-l info) para ver logs en consola
  command = ["salt-master", "-l", "info"]
}

# ============================================
# 🤖 7️⃣ Creación de múltiples Minions dinámicos
# ============================================

# 🔢 Definimos una lista de índices para generar los minions dinámicamente.
# Ejemplo: si var.minion_count = 3 → ["minion-1", "minion-2", "minion-3"]
locals {
  minion_indexes = toset([for i in range(var.minion_count) : i])

  # Creamos un mapa { "minion-1" = 0, "minion-2" = 1, ... }
  minions_map    = { for i in local.minion_indexes : format("minion-%d", i + 1) => i }
}

# ============================================
# 🚀 8️⃣ Despliegue de los contenedores Minion
# ============================================
resource "docker_container" "salt_minions" {
  for_each = local.minions_map   # Crea un contenedor por cada elemento del mapa

  name     = each.key            # Nombre del contenedor (minion-1, minion-2, ...)
  image    = docker_image.salt_minion_image.image_id
  hostname = each.key            # Nombre de host visible en la red Docker

  # 🔗 Conectamos el contenedor a la misma red que el master
  networks_advanced {
    name = docker_network.salt_net.name
  }

  # 🌐 Mapeo de puertos para NGINX
  # Cada minion escucha internamente en 8088, pero se le asigna un puerto diferente en el host
  # Ejemplo: minion-1 → 8080, minion-2 → 8081, etc.
  ports {
    internal = 8088
    external = var.nginx_base_port + each.value
  }

  # 🌍 Variable de entorno que indica a qué master debe conectarse
  # Terraform sustituye "SALT_MASTER=salt-master"
  env = ["SALT_MASTER=salt-master"]

  # ⚙️ Dependencia: los minions solo se lanzan cuando el master ya está creado
  depends_on = [docker_container.salt_master]
}

##########################################################
# ✅ Resultado final:
#  - 1 contenedor "salt-master" con puertos 4505–4506 expuestos
#  - N contenedores "salt-minion-X" conectados a la red salt-net
#  - Comunicación automática master ↔ minions
#  - Archivos .sls disponibles en /srv/salt
##########################################################
