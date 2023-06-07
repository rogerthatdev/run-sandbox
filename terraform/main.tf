locals {
  services = [
    "cloudbuild.googleapis.com",
    "run.googleapis.com",
    "artifactregistry.googleapis.com",
    "secretmanager.googleapis.com",
    "compute.googleapis.com"
  ]
}
data "google_project" "project" {
  project_id = var.project_id
}

resource "google_project_service" "required" {
  project  = var.project_id
  for_each = toset(local.services)
  service  = each.value
}

resource "time_sleep" "wait_30_seconds" {
  depends_on = [google_project_service.required]

  create_duration = "30s"
}


resource "google_secret_manager_secret" "nginx_config" {
  secret_id = "nginx_config"
  project   = var.project_id
  replication {
    automatic = true
  }
  depends_on = [time_sleep.wait_30_seconds]
}

data "local_file" "nginx_conifg" {
  filename = "${path.module}/files/nginx_config"
}

resource "google_secret_manager_secret_version" "nginx_config" {
  secret = google_secret_manager_secret.nginx_config.id

  secret_data = data.local_file.nginx_conifg.content
  depends_on  = [time_sleep.wait_30_seconds]
}
resource "google_artifact_registry_repository" "sidecar" {
  project       = var.project_id
  location      = "us-central1"
  repository_id = "app"
  format        = "DOCKER"
}

resource "google_secret_manager_secret_iam_member" "member" {
  project    = var.project_id
  secret_id  = google_secret_manager_secret.nginx_config.secret_id
  role       = "roles/secretmanager.secretAccessor"
  member     = "serviceAccount:${data.google_project.project.number}-compute@developer.gserviceaccount.com"
  depends_on = [time_sleep.wait_30_seconds]
}

output "ar_repo" {
  value = "${google_artifact_registry_repository.sidecar.location}-docker.pkg.dev/${google_artifact_registry_repository.sidecar.project}/${google_artifact_registry_repository.sidecar.name}"
}