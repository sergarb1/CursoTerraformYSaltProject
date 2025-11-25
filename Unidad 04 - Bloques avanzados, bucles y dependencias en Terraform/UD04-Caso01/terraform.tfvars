# -------------------------------------------------------
# Número de contenedores web (NGINX) que se van a crear
# En este caso se crearán 3 contenedores diferentes
# Cada uno tendrá su propio archivo HTML y nombre único
# -------------------------------------------------------
web_container_count = 3

# -------------------------------------------------------
# Este es el mensaje que se insertará dinámicamente
# en cada página web HTML generada.
# Puedes modificarlo y volver a aplicar (terraform apply)
# para ver cómo se actualizan todas las páginas.
# -------------------------------------------------------
html_message = "¡Esta es una web generada automáticamente!"

# -------------------------------------------------------
# Puerto del host local donde se expondrá el PRIMER contenedor
# Si estás usando `publish_first_port = true` en variables.tf,
# podrás acceder al contenedor en: http://localhost:8888
#
# IMPORTANTE: Solo se expone el primer contenedor.
# Los otros siguen funcionando en red privada (docker network).
# -------------------------------------------------------
exposed_port = 8888