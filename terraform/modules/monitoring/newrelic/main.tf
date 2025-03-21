terraform {
  required_providers {
    newrelic = {
      source  = "newrelic/newrelic"
      version = "~> 3.0"
    }
  }
}

locals {
  server_count = length(var.servers)
  server_names = join(", ", [for server in var.servers : server.name])
  # Crear condiciones WHERE para las consultas
  hostname_conditions = join(" OR ", [for server in var.servers : "hostname LIKE '${server.hostname_pattern}'"])
  # Crear condiciones para PostgreSQL
  postgres_servers             = [for server in var.servers : server if server.postgresql_enabled]
  postgres_hostname_conditions = length(local.postgres_servers) > 0 ? join(" OR ", [for server in local.postgres_servers : "hostname LIKE '${server.hostname_pattern}'"]) : ""
  postgres_process_conditions  = length(local.postgres_servers) > 0 ? join(" OR ", [for server in local.postgres_servers : "(hostname LIKE '${server.hostname_pattern}' AND processName = '${server.postgresql_process}')"]) : ""
}

resource "newrelic_one_dashboard" "ubuntu_postgres_dashboard" {
  name        = "Ubuntu 24.04 & PostgreSQL On-Premise - Mobile [${local.server_names}]"
  permissions = "public_read_write"

  page {
    name = "Servidores Ubuntu 24.04"

    widget_billboard {
      title  = "Estado de Hosts"
      row    = 1
      column = 1
      width  = 4
      height = 2

      nrql_query {
        query = "SELECT latest(host.status) FROM SystemSample WHERE ${local.hostname_conditions} FACET hostname"
      }
    }

    widget_line {
      title  = "CPU Utilization"
      row    = 3
      column = 1
      width  = 4
      height = 3

      nrql_query {
        query = "SELECT average(cpuSystemPercent) AS 'System', average(cpuUserPercent) AS 'User', average(cpuIdlePercent) AS 'Idle' FROM SystemSample WHERE ${local.hostname_conditions} FACET hostname TIMESERIES"
      }
    }

    widget_area {
      title  = "Memory Usage"
      row    = 6
      column = 1
      width  = 4
      height = 3

      nrql_query {
        query = "SELECT average(memoryUsedBytes)/1024/1024/1024 AS 'Memory Used (GB)', average(memoryFreeBytes)/1024/1024/1024 AS 'Memory Free (GB)' FROM SystemSample WHERE ${local.hostname_conditions} FACET hostname TIMESERIES"
      }
    }

    widget_line {
      title  = "Disk I/O"
      row    = 9
      column = 1
      width  = 4
      height = 3

      nrql_query {
        query = "SELECT average(ioReadBytesPerSecond)/1024/1024 AS 'Read MB/s', average(ioWriteBytesPerSecond)/1024/1024 AS 'Write MB/s' FROM SystemSample WHERE ${local.hostname_conditions} FACET hostname TIMESERIES"
      }
    }

    widget_line {
      title  = "Consumo de Energía"
      row    = 12
      column = 1
      width  = 4
      height = 3

      nrql_query {
        query = "SELECT average(powerUsageWatts) AS 'Consumo (Watts)' FROM SystemPowerSample WHERE ${local.hostname_conditions} FACET hostname TIMESERIES"
      }
    }
  }

  dynamic "page" {
    for_each = length(local.postgres_servers) > 0 ? [1] : []
    content {
      name = "PostgreSQL"

      widget_line {
        title  = "Conexiones Activas"
        row    = 1
        column = 1
        width  = 4
        height = 3

        nrql_query {
          query = "SELECT average(provider.connectionCount.active) FROM PostgresqlSample WHERE ${local.postgres_hostname_conditions} FACET hostname TIMESERIES"
        }
      }

      widget_line {
        title  = "Transacciones por Segundo"
        row    = 4
        column = 1
        width  = 4
        height = 3

        nrql_query {
          query = "SELECT rate(sum(provider.xact.commits) + sum(provider.xact.rollbacks), 1 second) AS 'TPS' FROM PostgresqlSample WHERE ${local.postgres_hostname_conditions} FACET hostname TIMESERIES"
        }
      }

      widget_billboard {
        title  = "Cache Hit Ratio"
        row    = 7
        column = 1
        width  = 4
        height = 3

        nrql_query {
          query = "SELECT average(provider.bufferCache.hitRatio) * 100 AS 'Hit Ratio %' FROM PostgresqlSample WHERE ${local.postgres_hostname_conditions} FACET hostname"
        }
      }

      widget_line {
        title  = "Consumo de Energía PostgreSQL"
        row    = 10
        column = 1
        width  = 4
        height = 3

        nrql_query {
          query = "SELECT average(processCpuPercent) * 3.5 AS 'Est. Power (Watts)' FROM ProcessSample WHERE ${local.postgres_process_conditions} FACET hostname, processName TIMESERIES"
        }
      }
    }
  }

  page {
    name = "Resumen de Energía"

    widget_billboard {
      title  = "Consumo Total de Energía"
      row    = 1
      column = 1
      width  = 4
      height = 2

      nrql_query {
        query = "SELECT latest(powerUsageWatts) AS 'Watts' FROM SystemPowerSample WHERE ${local.hostname_conditions} FACET hostname"
      }
    }

    widget_area {
      title  = "Histórico de Consumo por Hora"
      row    = 3
      column = 1
      width  = 4
      height = 4

      nrql_query {
        query = "SELECT average(powerUsageWatts) AS 'Consumo (Watts)' FROM SystemPowerSample WHERE ${local.hostname_conditions} FACET hostname TIMESERIES 1 hour"
      }
    }

    widget_pie {
      title  = "Eficiencia Energética"
      row    = 7
      column = 1
      width  = 4
      height = 4

      nrql_query {
        query = "SELECT average(powerUsageWatts) AS 'Watts' FROM SystemPowerSample WHERE ${local.hostname_conditions} FACET hostname, osName, kernelVersion"
      }
    }

    widget_bar {
      title  = "Consumo por Proceso (Top 5)"
      row    = 11
      column = 1
      width  = 4
      height = 4

      nrql_query {
        query = "SELECT average(processCpuPercent) * 3.5 AS 'Est. Power (Watts)' FROM ProcessSample WHERE ${local.hostname_conditions} FACET hostname, processDisplayName LIMIT 5"
      }
    }
  }
}
