variable "project_id" {
    type = string
    default = "cloud-run-sandbox-388917"
}

locals {
  services = [
    "cloudbuild.googleapis.com",
    "run.googleapis.com",
    "artifactregistry.googleapis.com",
    "secretmanager.googleapis.com",
    "compute.googleapis.com"
  ]
}


resource "google_project_service" "required" {
  project = var.project_id
  for_each = toset(local.services)
  service = each.value
}

resource "google_secret_manager_secret" "nginx_config" {
  secret_id = "nginx-config"
  project = var.project_id
  replication {
    automatic = true
  }
}

data "local_file" "nginx_conifg" {
    filename = "${path.module}/files/nginx_config"
}

resource "google_secret_manager_secret_version" "nginx_config" {
  secret = google_secret_manager_secret.nginx_config.id

  secret_data = data.local_file.nginx_conifg.content
}


# Secret manager secret accessor for service account
data "google_compute_default_service_account" "default" {
    project = var.project_id
}


resource "google_secret_manager_secret_iam_member" "member" {
  project = var.project_id
  secret_id = google_secret_manager_secret.nginx_config.secret_id
  role = "roles/secretmanager.secretAccessor"
  member = "serviceAccount:${data.google_compute_default_service_account.default.email}"
}

