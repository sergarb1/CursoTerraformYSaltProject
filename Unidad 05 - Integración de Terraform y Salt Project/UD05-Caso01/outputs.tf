##############################################
# 📤 Outputs de Terraform
# Muestran información útil una vez desplegada
# la infraestructura: IPs del master y minions,
# y los puertos expuestos en el host.
##############################################

# ============================================
# 🧠 1️⃣ Dirección IP del contenedor Salt Master
# ============================================
output "master_ip" {
  # Valor que devuelve la IP interna asignada al master
  # en la red Docker "salt-net"
  value = docker_container.salt_master.network_data[0].ip_address
  # Ejemplo de salida: "172.18.0.2"
}

# ============================================
# 🤖 2️⃣ Direcciones IP de todos los minions
# ============================================
output "minions_ips" {
  # Usamos un bucle "for" para recorrer todos los minions
  # creados dinámicamente y construir un mapa con:
  #  { "minion-1" = "172.18.0.3", "minion-2" = "172.18.0.4", ... }
  value = {
    for k, v in docker_container.salt_minions :
    k => v.network_data[0].ip_address
  }
}

# ============================================
# 🌐 3️⃣ Puertos HTTP expuestos en el host (NGINX)
# ============================================
output "host_ports" {
  # Crea un mapa con los nombres de los minions
  # y los puertos del host asignados por Terraform.
  # Ejemplo de salida:
  # {
  #   "minion-1" = 8080
  #   "minion-2" = 8081
  #   "minion-3" = 8082
  # }
  value = {
    for k, v in docker_container.salt_minions :
    k => v.ports[0].external
  }
}
