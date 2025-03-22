module "newrelic_ubuntu_postgres_dashboard" {
  source = "../../modules/monitoring/newrelic"

  newrelic_account_id = var.newrelic_account_id
  newrelic_api_key    = var.newrelic_api_key
  newrelic_region     = var.newrelic_region
  environment         = "prod"

  servers = [
    {
      name               = "midas"
      hostname_pattern   = "%midas%"
      description        = "Principal Server in midas"
      postgresql_enabled = true
      postgresql_process = "postgres"
      tags = {
        role = "production"
        type = "on-premise"
        location = "mx-coahuila"
      }
    }
  ]
}
