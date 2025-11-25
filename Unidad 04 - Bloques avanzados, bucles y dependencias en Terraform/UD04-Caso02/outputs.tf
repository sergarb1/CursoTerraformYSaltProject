# Mostramos cada contenedor web creado, su nombre y su HTML
output "contenedores_web" {
  description = "Contenedores web desplegados"
  value = [
    for i in docker_container.web :
    {
      nombre  = i.name
      archivo = abspath(tolist(i.volumes)[0].host_path)
    }
  ]
}

# URL donde puedes acceder al balanceador reverse proxy
output "url_balanceador" {
  description = "URL del balanceador reverse proxy"
  value       = "http://localhost:${var.exposed_port}"
}
