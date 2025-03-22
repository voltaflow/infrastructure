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
  
  // Conditions to identify hosts
  hostname_conditions = join(" OR ", [
    for server in var.servers : "hostname LIKE '${server.hostname_pattern}'"
  ])
  
  // Filtering for PostgreSQL-enabled servers
  postgres_servers             = [for server in var.servers : server if server.postgresql_enabled]
  postgres_hostname_conditions = length(local.postgres_servers) > 0 ? join(" OR ", [for server in local.postgres_servers : "hostname LIKE '${server.hostname_pattern}'"]) : ""
  postgres_process_conditions  = length(local.postgres_servers) > 0 ? join(" OR ", [
    for server in local.postgres_servers : "(hostname LIKE '${server.hostname_pattern}' AND processName = '${server.postgresql_process}')"
  ]) : ""
}

resource "newrelic_one_dashboard" "ubuntu_postgres_dashboard" {
  name        = "Ubuntu 24.04 & PostgreSQL On-Premise - Mobile [${local.server_names}]"
  permissions = "public_read_write"

  // ------------------------------------------------------------------------
  // PAGE 1: SYSTEM RESOURCE MONITORING
  // ------------------------------------------------------------------------
  page {
    name = "Ubuntu 24.04 Servers"

    // 1) Host Status (showing current CPU usage as an indicator)
    widget_billboard {
      title  = "Host Status (Current CPU)"
      row    = 1
      column = 1
      width  = 4
      height = 2

      nrql_query {
        query = <<-NRQL
          SELECT latest(cpuUserPercent) AS 'CPU (%)'
          FROM SystemSample
          WHERE ${local.hostname_conditions}
          FACET hostname
        NRQL
      }
    }

    // 2) CPU Utilization
    widget_line {
      title  = "CPU Utilization"
      row    = 3
      column = 1
      width  = 4
      height = 3

      nrql_query {
        query = <<-NRQL
          SELECT average(cpuSystemPercent) AS 'System',
                 average(cpuUserPercent)   AS 'User',
                 average(cpuIdlePercent)   AS 'Idle'
          FROM SystemSample
          WHERE ${local.hostname_conditions}
          FACET hostname
          TIMESERIES
        NRQL
      }
    }

    // 3) Memory Usage
    widget_area {
      title  = "Memory Usage"
      row    = 6
      column = 1
      width  = 4
      height = 3

      nrql_query {
        query = <<-NRQL
          SELECT average(memoryUsedBytes)/1024/1024/1024 AS 'Memory Used (GB)',
                 average(memoryFreeBytes)/1024/1024/1024 AS 'Memory Free (GB)'
          FROM SystemSample
          WHERE ${local.hostname_conditions}
          FACET hostname
          TIMESERIES
        NRQL
      }
    }

    // 4) Disk I/O
    widget_line {
      title  = "Disk I/O"
      row    = 9
      column = 1
      width  = 4
      height = 3

      nrql_query {
        query = <<-NRQL
          SELECT average(ioReadBytesPerSecond)/1024/1024 AS 'Read MB/s',
                 average(ioWriteBytesPerSecond)/1024/1024 AS 'Write MB/s'
          FROM SystemSample
          WHERE ${local.hostname_conditions}
          FACET hostname
          TIMESERIES
        NRQL
      }
    }

    // 5) Estimated Energy Consumption (based on CPU usage)
    widget_line {
      title  = "Estimated Energy Consumption (approx)"
      row    = 12
      column = 1
      width  = 4
      height = 3

      nrql_query {
        query = <<-NRQL
          SELECT average(cpuUserPercent)*3.5 AS 'Consumption (Watts)'
          FROM SystemSample
          WHERE ${local.hostname_conditions}
          FACET hostname
          TIMESERIES
        NRQL
      }
    }
  }

  // ------------------------------------------------------------------------
  // PAGE 2: POSTGRES MONITORING (only for PostgreSQL-enabled servers)
  // ------------------------------------------------------------------------
  dynamic "page" {
    for_each = length(local.postgres_servers) > 0 ? [1] : []
    content {
      name = "PostgreSQL"

      widget_line {
        title  = "Active Connections"
        row    = 1
        column = 1
        width  = 4
        height = 3

        nrql_query {
          query = <<-NRQL
            SELECT average(provider.connectionCount.active)
            FROM PostgresqlSample
            WHERE ${local.postgres_hostname_conditions}
            FACET hostname
            TIMESERIES
          NRQL
        }
      }

      widget_line {
        title  = "Transactions Per Second (TPS)"
        row    = 4
        column = 1
        width  = 4
        height = 3

        nrql_query {
          query = <<-NRQL
            SELECT rate(sum(provider.xact.commits) + sum(provider.xact.rollbacks), 1 second) AS 'TPS'
            FROM PostgresqlSample
            WHERE ${local.postgres_hostname_conditions}
            FACET hostname
            TIMESERIES
          NRQL
        }
      }

      widget_billboard {
        title  = "Cache Hit Ratio"
        row    = 7
        column = 1
        width  = 4
        height = 3

        nrql_query {
          query = <<-NRQL
            SELECT average(provider.bufferCache.hitRatio) * 100 AS 'Hit Ratio %'
            FROM PostgresqlSample
            WHERE ${local.postgres_hostname_conditions}
            FACET hostname
          NRQL
        }
      }

      widget_line {
        title  = "Estimated Energy Consumption for PostgreSQL (approx)"
        row    = 10
        column = 1
        width  = 4
        height = 3

        nrql_query {
          query = <<-NRQL
            SELECT average(processCpuPercent) * 3.5 AS 'Estimated Power (Watts)'
            FROM ProcessSample
            WHERE ${local.postgres_process_conditions}
            FACET hostname, processName
            TIMESERIES
          NRQL
        }
      }
    }
  }

  // ------------------------------------------------------------------------
  // PAGE 3: ENERGY SUMMARY (approximate)
  // ------------------------------------------------------------------------
  page {
    name = "Energy Summary (approx)"

    widget_billboard {
      title  = "Total Energy Consumption"
      row    = 1
      column = 1
      width  = 4
      height = 2

      nrql_query {
        query = <<-NRQL
          SELECT latest(cpuUserPercent) * 3.5 AS 'Watts (approx)'
          FROM SystemSample
          WHERE ${local.hostname_conditions}
          FACET hostname
        NRQL
      }
    }

    widget_area {
      title  = "Hourly Consumption History"
      row    = 3
      column = 1
      width  = 4
      height = 4

      nrql_query {
        query = <<-NRQL
          SELECT average(cpuUserPercent)*3.5 AS 'Consumption (Watts)'
          FROM SystemSample
          WHERE ${local.hostname_conditions}
          FACET hostname
          TIMESERIES 1 hour
        NRQL
      }
    }

    widget_pie {
      title  = "Energy Efficiency (approx)"
      row    = 7
      column = 1
      width  = 4
      height = 4

      nrql_query {
        query = <<-NRQL
          SELECT average(cpuUserPercent)*3.5 AS 'Watts'
          FROM SystemSample
          WHERE ${local.hostname_conditions}
          FACET hostname, osName, kernelVersion
        NRQL
      }
    }

    widget_bar {
      title  = "Top 5 Processes by Energy Consumption"
      row    = 11
      column = 1
      width  = 4
      height = 4

      nrql_query {
        query = <<-NRQL
          SELECT average(processCpuPercent)*3.5 AS 'Estimated Power (Watts)'
          FROM ProcessSample
          WHERE ${local.hostname_conditions}
          FACET hostname, processDisplayName
          LIMIT 5
        NRQL
      }
    }

    widget_billboard {
      title  = "Monthly Energy Cost (approx)"
      row    = 15
      column = 1
      width  = 4
      height = 2

      nrql_query {
        query = <<-NRQL
          SELECT (latest(cpuUserPercent)*3.5/1000 * 720 * 5.7) AS 'Monthly Cost (MXN)'
          FROM SystemSample
          WHERE ${local.hostname_conditions}
          FACET hostname
        NRQL
      }
    }
  }
}