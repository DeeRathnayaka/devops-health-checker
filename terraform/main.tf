terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "4.5.0"
    }
  }
}

provider "docker" {
  host = "ssh://healthcheck@192.168.15.50:22"

  ssh_opts = [
    "-i",
    "/home/asus/.ssh/id_ed25519",
    "-o",
    "IdentitiesOnly=yes"
  ]
}

# --------------------------------------------------
# Network
# --------------------------------------------------

resource "docker_network" "health_checker" {
  name = var.network_name
}

# --------------------------------------------------
# PostgreSQL
# --------------------------------------------------

resource "docker_volume" "postgres_data" {
  name = "health-checker-postgres-data"
}

resource "docker_image" "postgres" {
  name = "postgres:17"
}

resource "docker_container" "postgres" {
  name  = "postgres"
  image = docker_image.postgres.image_id

  restart = "no"

  env = [
    "POSTGRES_DB=${var.db_name}",
    "POSTGRES_USER=${var.db_user}",
    "POSTGRES_PASSWORD=${var.db_password}"
  ]

  volumes {
    volume_name    = docker_volume.postgres_data.name
    container_path = "/var/lib/postgresql/data"
  }

  volumes {
    host_path      = abspath("${path.module}/../db/init")
    container_path = "/docker-entrypoint-initdb.d"
    read_only      = true
  }

  networks_advanced {
    name = docker_network.health_checker.name
  }

  log_driver = "journald"
}

# --------------------------------------------------
# Health Checker
# --------------------------------------------------

resource "docker_image" "health_checker" {
  name = var.image
}

resource "docker_container" "health_checker" {
  name  = var.container_name
  image = docker_image.health_checker.image_id

  restart = "no"

  ports {
    internal = 8000
    external = var.host_port
  }

  networks_advanced {
    name = docker_network.health_checker.name
  }

  env = [
    "DB_HOST=${var.db_host}",
    "DB_PORT=${var.db_port}",
    "DB_NAME=${var.db_name}",
    "DB_USER=${var.db_user}",
    "DB_PASSWORD=${var.db_password}"
  ]

  log_driver = "journald"

  depends_on = [
    docker_container.postgres
  ]
}
