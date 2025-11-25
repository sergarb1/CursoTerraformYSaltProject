# 🔍 Definimos una salida llamada "token_value"
output "token_value" {
  # Descripción de lo que representa esta salida
  description = "Token generado aleatoriamente"
  
  # Valor que se mostrará: el resultado del recurso random_password llamado secure_token
  value       = random_password.secure_token.result
  
  # Marcamos la salida como sensible para que no se muestre en texto plano en los logs o consola
  sensitive   = true
}

# 📂 Definimos otra salida llamada "file_path"
output "file_path" {
  # Descripción de la salida: mostrará la ruta del archivo creado localmente
  description = "Ruta del archivo local generado"
  
  # Valor que se mostrará: el nombre (ruta) del archivo generado por el recurso local_file token_file
  value       = local_file.token_file.filename
}