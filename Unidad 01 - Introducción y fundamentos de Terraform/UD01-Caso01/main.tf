# 🔧 Declaración de los providers necesarios para el proyecto
terraform {
  required_providers {
    local = {
      source  = "hashicorp/local"     # Provider para manejar archivos locales
      version = "~> 2.0"
    }
    null = {
      source  = "hashicorp/null"      # Provider para ejecutar comandos locales
      version = "~> 3.0"
    }
    random = {
      source  = "hashicorp/random"    # Provider para generar valores aleatorios
      version = "~> 3.0"
    }
  }
}

# 🎛️ Inicialización de los providers
provider "local" {}   # Sin configuración adicional
provider "null"  {}   # Sin configuración adicional
provider "random" {}  # Sin configuración adicional

# 🔐 Genera un token aleatorio
resource "random_password" "secure_token" {
  length  = 12        # Longitud del token
  special = true      # Incluye caracteres especiales
}

# 📝 Crea un archivo local con el token
resource "local_file" "token_file" {
  filename = "${path.module}/token.txt"                            # Ruta del archivo
  content  = "Token generado: ${random_password.secure_token.result}"  # Contenido del archivo
}

# 🖥️ Muestra un mensaje en la terminal
resource "null_resource" "notify" {
  provisioner "local-exec" {
    command = "echo '✅ Archivo creado exitosamente con token aleatorio.'"  # Mensaje de confirmación
  }
}