variable "minion_count" {
  description = "Número de minions a crear"
  type        = number
  default     = 2
}

variable "nginx_base_port" {
  description = "Puerto base para exponer los servicios HTTP de los minions"
  type        = number
  default     = 8080
}
