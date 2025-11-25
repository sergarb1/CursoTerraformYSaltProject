terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = ">= 2.20.0"
    }
  }
}

provider "docker" {}

########################
# 🕸️ RED DOCKER PRIVADA
########################
resource "docker_network" "wp_net" {
  name = "wordpress_monitoring_net"
}

########################
# 💾 VOLUMENES PERSISTENTES
########################
resource "docker_volume" "mysql_data" {
  name = "mysql_data_volume"
}

resource "docker_volume" "wordpress_data" {
  name = "wordpress_data_volume"
}

########################
# 🗃️ MYSQL DATABASE
########################
resource "docker_image" "mysql" {
  name = "mysql:5.7"
}

resource "docker_container" "mysql" {
  name  = "mysql_db"
  image = docker_image.mysql.image_id

  networks_advanced {
    name = docker_network.wp_net.name
  }

  env = [
    "MYSQL_ROOT_PASSWORD=${var.mysql_root_password}",
    "MYSQL_DATABASE=${var.mysql_database}",
    "MYSQL_USER=${var.mysql_user}",
    "MYSQL_PASSWORD=${var.mysql_password}"
  ]

  mounts {
    target = "/var/lib/mysql"
    source = docker_volume.mysql_data.name
    type   = "volume"
  }

  ports {
    internal = 3306
    external = 3306
  }
}

########################
# 🌐 WORDPRESS APP
########################
resource "docker_image" "wordpress" {
  name = "wordpress:latest"
}

resource "docker_container" "wordpress" {
  name  = "wordpress"
  image = docker_image.wordpress.image_id

  networks_advanced {
    name = docker_network.wp_net.name
  }

  env = [
    "WORDPRESS_DB_HOST=${docker_container.mysql.name}:3306",
    "WORDPRESS_DB_NAME=${var.mysql_database}",
    "WORDPRESS_DB_USER=${var.mysql_user}",
    "WORDPRESS_DB_PASSWORD=${var.mysql_password}"
  ]

  mounts {
    target = "/var/www/html"
    source = docker_volume.wordpress_data.name
    type   = "volume"
  }

  ports {
    internal = 80
    external = var.wordpress_port
  }

  depends_on = [docker_container.mysql]
}

########################
# ⚙️ NODE EXPORTER
########################
resource "docker_image" "node_exporter" {
  name = "prom/node-exporter:latest"
}

resource "docker_container" "node_exporter" {
  name  = "node_exporter"
  image = docker_image.node_exporter.image_id

  networks_advanced {
    name = docker_network.wp_net.name
  }

  ports {
    internal = 9100
    external = var.node_exporter_port
  }
}

########################
# 📊 PROMETHEUS
########################
resource "docker_image" "prometheus" {
  name = "prom/prometheus:latest"
}

resource "docker_container" "prometheus" {
  name  = "prometheus"
  image = docker_image.prometheus.image_id

  networks_advanced {
    name = docker_network.wp_net.name
  }

  mounts {
    type   = "bind"
    source = abspath("${path.module}/prometheus.yml")
    target = "/etc/prometheus/prometheus.yml"
  }

  ports {
    internal = 9090
    external = var.prometheus_port
  }

  depends_on = [docker_container.node_exporter]
}

########################
# 📈 GRAFANA
########################
resource "docker_image" "grafana" {
  name = "grafana/grafana:latest"
}

resource "docker_container" "grafana" {
  name  = "grafana"
  image = docker_image.grafana.image_id

  networks_advanced {
    name = docker_network.wp_net.name
  }

  env = [
    "GF_SECURITY_ADMIN_USER=${var.grafana_user}",
    "GF_SECURITY_ADMIN_PASSWORD=${var.grafana_password}"
  ]

  ports {
    internal = 3000
    external = var.grafana_port
  }

  depends_on = [docker_container.prometheus]
}
