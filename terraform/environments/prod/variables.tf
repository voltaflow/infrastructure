variable "newrelic_account_id" {
  description = "The New Relic account ID"
  type        = string
  # No se incluye valor predeterminado por seguridad
}

variable "newrelic_api_key" {
  description = "The New Relic API key"
  type        = string
  sensitive   = true
  default     = null # Esto permitirá obtenerlo de la variable de entorno TF_VAR_newrelic_api_key
}

variable "newrelic_region" {
  description = "The New Relic region (US or EU)"
  type        = string
  default     = "US"
}
