variable "image" {
  description = "Health checker container image"
  type        = string

  default = "ghcr.io/deerathnayaka/devops-health-checker:5ef50255b86a83718eb85d84466967511e625022"
}

variable "container_name" {
  description = "Docker container name"
  type        = string
  default     = "health-checker"
}

variable "network_name" {
  description = "Docker network name"
  type        = string
  default     = "health-checker-network"
}

variable "host_port" {
  description = "Host port exposed for the health checker"
  type        = number
  default     = 8000
}

variable "db_host" {
  description = "Database hostname"
  type        = string
  default     = "postgres"
}

variable "db_port" {
  description = "Database port"
  type        = number
  default     = 5432
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "healthdb"
}

variable "db_user" {
  description = "Database username"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}
