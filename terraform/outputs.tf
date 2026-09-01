output "container_name" {
  description = "Provisioned container name"
  value       = docker_container.health_checker.name
}

output "container_id" {
  description = "Provisioned container ID"
  value       = docker_container.health_checker.id
}

output "health_checker_url" {
  description = "Health checker endpoint"
  value       = "http://192.168.15.50:${var.host_port}/health"
}

output "docker_network" {
  description = "Docker network used by the application"
  value       = docker_network.health_checker.name
}
