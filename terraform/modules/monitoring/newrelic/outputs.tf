output "dashboard_id" {
  description = "The ID of the created NewRelic dashboard"
  value       = newrelic_one_dashboard.ubuntu_postgres_dashboard.id
}

output "dashboard_url" {
  description = "The URL of the created NewRelic dashboard"
  value       = "https://one.newrelic.com/dashboards/${newrelic_one_dashboard.ubuntu_postgres_dashboard.id}"
}