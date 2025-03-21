# NewRelic Dashboard para Ubuntu 24.04 y PostgreSQL

Este módulo de Terraform crea un dashboard en NewRelic optimizado para visualización móvil, enfocado en el monitoreo de:
- Múltiples servidores Ubuntu 24.04 on-premise
- Bases de datos PostgreSQL
- Métricas de consumo de energía

## Requisitos Previos

- Tener instalado y configurado el agente de NewRelic en los servidores Ubuntu 24.04
- Tener configurada la integración de PostgreSQL con NewRelic
- Tener configuradas las API keys de NewRelic

## Uso

```hcl
module "newrelic_ubuntu_postgres_dashboard" {
  source = "./modules/monitoring/newrelic"

  newrelic_account_id = "YOUR_ACCOUNT_ID"
  environment         = "prod"
  
  servers = [
    {
      name             = "servidor-principal"
      hostname_pattern = "%ubuntu-prod-main%"
      description      = "Servidor principal de producción"
      postgresql_enabled = true
      postgresql_process = "postgres"
      tags = {
        role = "main"
        env  = "production"
      }
    },
    {
      name             = "servidor-db"
      hostname_pattern = "%ubuntu-prod-db%"
      description      = "Servidor dedicado de base de datos"
      postgresql_enabled = true
      postgresql_process = "postgresql"
      tags = {
        role = "database"
        env  = "production"
      }
    },
    {
      name             = "servidor-api"
      hostname_pattern = "%ubuntu-prod-api%"
      description      = "Servidor de API"
      postgresql_enabled = false
      tags = {
        role = "api"
        env  = "production"
      }
    }
  ]
}
```

## Variables

| Nombre | Descripción | Tipo | Default |
|--------|-------------|------|---------|
| newrelic_account_id | ID de cuenta de NewRelic | string | - |
| environment | Entorno (prod, dev, staging) | string | "prod" |
| servers | Lista de servidores a monitorear | list(object) | [] |

### Estructura del objeto `servers`

```hcl
{
  name                 = string           # Nombre descriptivo del servidor
  hostname_pattern     = string           # Patrón para filtrar el hostname en las consultas
  description          = string, opcional # Descripción del servidor
  postgresql_enabled   = bool, opcional   # Indica si debe monitorearse PostgreSQL en este servidor
  postgresql_process   = string, opcional # Nombre del proceso PostgreSQL (default: "postgres")
  tags                 = map, opcional    # Etiquetas para categorizar el servidor
}
```

## Outputs

| Nombre | Descripción |
|--------|-------------|
| dashboard_id | ID del dashboard creado |
| dashboard_url | URL para acceder al dashboard |

## Características del Dashboard

### Página: Servidores Ubuntu 24.04
- Estado de los hosts
- Utilización de CPU por servidor
- Uso de memoria por servidor
- Operaciones de disco (I/O) por servidor
- Consumo de energía por servidor

### Página: PostgreSQL (solo para servidores con postgresql_enabled=true)
- Conexiones activas por servidor
- Transacciones por segundo por servidor
- Ratio de caché por servidor
- Consumo de energía relacionado con PostgreSQL por servidor

### Página: Resumen de Energía
- Consumo total actual por servidor
- Histórico por hora por servidor
- Eficiencia energética por servidor y versión del sistema
- Consumo por proceso (Top 5) por servidor

## Personalización

Para personalizar las métricas o consultas, modifique los bloques `nrql_query` en `main.tf` con las consultas NRQL apropiadas para su entorno.

## Acceso Móvil

Este dashboard está diseñado específicamente para ser visualizado en la aplicación móvil de NewRelic, optimizando el tamaño y disposición de los widgets para pantallas pequeñas.