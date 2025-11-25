terraform {
  # Aquí definimos qué proveedores (providers) vamos a usar en este proyecto
  required_providers {
    # Declaramos que vamos a usar el provider llamado "docker"
    docker = {
      # Especificamos el origen del provider: "kreuzwerker/docker"
      source = "kreuzwerker/docker"

      # Indicamos que queremos usar la versión 2.20.0 o superior del provider Docker
      # Es buena práctica fijar versiones o rangos para evitar problemas con futuras actualizaciones
      version = ">= 2.20.0"
    }
  }
}

# Proveedor Docker local
provider "docker" {}

# 📡 Creamos una red Docker interna para conectar todos los contenedores
resource "docker_network" "wp_net" {
  name = "wordpress_net"
}

# 💾 Creamos un volumen persistente para los datos de MySQL
resource "docker_volume" "mysql_data" {
  name = "mysql_data"
}

# 🐬 Imagen de MySQL
resource "docker_image" "mysql" {
  name = var.mysql_image
}

# 🐬 Contenedor de MySQL
resource "docker_container" "mysql" {
  name  = "mysql_db"
  image = docker_image.mysql.name

  # Variables de entorno necesarias para inicializar la base de datos
  env = [
    "MYSQL_ROOT_PASSWORD=${var.mysql_root_password}",
    "MYSQL_DATABASE=${var.mysql_database}"
  ]

  # Montamos el volumen para persistencia de datos
  volumes {
    volume_name    = docker_volume.mysql_data.name
    container_path = "/var/lib/mysql"
  }

  # Lo conectamos a la red interna y le damos el alias "db"
  networks_advanced {
    name    = docker_network.wp_net.name
    aliases = ["db"]
  }

  # Exponemos el puerto 3306 internamente (opcional)
  ports {
    internal = 3306
    external = 3306
  }
}

# 🌐 Imagen de WordPress
resource "docker_image" "wordpress" {
  name = var.wordpress_image
}

# 🌐 Contenedor WordPress
resource "docker_container" "wordpress" {
  name  = "wordpress_app"
  image = docker_image.wordpress.name

  # Variables de entorno para que WordPress se conecte a MySQL
  env = [
    "WORDPRESS_DB_HOST=db:3306",                 # db = alias en la red Docker
    "WORDPRESS_DB_NAME=${var.mysql_database}",
    "WORDPRESS_DB_USER=root",
    "WORDPRESS_DB_PASSWORD=${var.mysql_root_password}"
  ]

  # Conectado a la misma red que MySQL
  networks_advanced {
    name = docker_network.wp_net.name
  }

  # Puerto 80 interno expuesto en el puerto local definido por el usuario
  ports {
    internal = 80
    external = var.wordpress_port
  }

  # Este contenedor depende del de MySQL para arrancar correctamente
  depends_on = [docker_container.mysql]
}

# ⚙️ Imagen de phpMyAdmin
resource "docker_image" "phpmyadmin" {
  name = var.phpmyadmin_image
}

# ⚙️ Contenedor phpMyAdmin
resource "docker_container" "phpmyadmin" {
  name  = "phpmyadmin_ui"
  image = docker_image.phpmyadmin.name

  # Variables de entorno para conectarse a MySQL
  env = [
    "PMA_HOST=db",                               # Usamos el alias de red
    "PMA_USER=root",
    "PMA_PASSWORD=${var.mysql_root_password}"
  ]

  # Conectado a la misma red que los demás
  networks_advanced {
    name = docker_network.wp_net.name
  }

  # Puerto 80 interno expuesto como 8081 localmente (por defecto)
  ports {
    internal = 80
    external = var.phpmyadmin_port
  }

  # También depende de que MySQL esté funcionando primero
  depends_on = [docker_container.mysql]
}
