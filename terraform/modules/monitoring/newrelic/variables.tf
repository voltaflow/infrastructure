variable "newrelic_account_id" {
  description = "The New Relic account ID"
  type        = string
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

variable "environment" {
  description = "The environment (e.g. prod, dev, staging)"
  type        = string
  default     = "prod"
}

variable "servers" {
  description = "List of servers to monitor with their configurations"
  type = list(object({
    name               = string
    hostname_pattern   = string
    description        = optional(string, "")
    postgresql_enabled = optional(bool, true)
    postgresql_process = optional(string, "postgres")
    tags               = optional(map(string), {})
  }))

  validation {
    condition     = length(var.servers) > 0
    error_message = "At least one server must be specified."
  }
}
