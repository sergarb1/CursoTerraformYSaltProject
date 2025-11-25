# -------------------------------------------------------
# Output principal que devuelve una lista con la información
# de cada contenedor web creado (uno por recurso docker_container.web)
# 
# Se muestra:
# - El nombre del contenedor
# - El puerto en el host (si está expuesto)
# - La ruta al archivo HTML que se montó
# - El nombre de la red Docker a la que pertenece
# -------------------------------------------------------
output "contenedores_web" {
  description = "Lista de contenedores desplegados"

  value = [
    for i in docker_container.web :   # Recorremos cada contenedor web creado
    {
      nombre   = i.name                                  # Nombre único del contenedor (nginx-random)
      puerto   = try(i.ports[0].external, "No expuesto") # Si tiene un puerto expuesto, lo muestra; si no, indica "No expuesto"
      archivo  = abspath(tolist(i.volumes)[0].host_path) # 🔧 Convertimos el set en lista antes de acceder. Ruta local al archivo HTML montado
      red      = docker_network.terraform_net.name       # Nombre de la red Docker utilizada (terraform-net)
    }
  ]
}

# -------------------------------------------------------
# Output que devuelve la URL local del contenedor principal
# Solo muestra la URL si publish_first_port = true
# En caso contrario, informa que no está expuesto
# 
# Esto permite al usuario abrir el navegador y acceder al contenedor:
# Ejemplo: http://localhost:8888
# -------------------------------------------------------
output "url_local" {
  description = "URL del contenedor principal (si está expuesto)"

  # Si publish_first_port = true, devuelve la URL
  # Si no, muestra "No expuesto"
  value = var.publish_first_port ? "http://localhost:${var.exposed_port}" : "No expuesto"
}