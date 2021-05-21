resource "google_service_account" "ci_user" {
  project      = var.project
  account_id   = "ci-user-${var.env}"
  display_name = "CI User Service Account"
}

resource "google_service_account_key" "ci_user_key" {
  service_account_id = google_service_account.ci_user.name
}

resource "google_project_iam_member" "ci_user_viewer_binding" {
  project = var.project
  member  = "serviceAccount:${google_service_account.ci_user.email}"
  role    = "roles/viewer"
}
resource "google_project_iam_member" "ci_user_object_viewer_binding" {
  project = var.project
  member  = "serviceAccount:${google_service_account.ci_user.email}"
  role    = "roles/storage.objectViewer"
}
resource "google_storage_bucket_iam_member" "ci_user_tfstate_admin" {
  bucket = google_storage_bucket.infra_tf_state.name
  member = "serviceAccount:${google_service_account.ci_user.email}"
  role   = "roles/storage.admin"
}
resource "google_storage_bucket_iam_member" "ci_user_gcr_admin" {
  bucket = "asia.artifacts.eitan-${var.env}.appspot.com"
  member = "serviceAccount:${google_service_account.ci_user.email}"
  role   = "roles/storage.admin"
}


#######################################
# Kubernetes Service Account
#######################################
resource "google_service_account" "account_service" {
  project      = var.project
  account_id   = "account-service-${var.env}"
  display_name = "account-service KSA Service Account"
}

resource "google_service_account" "eitan_service" {
  project      = var.project
  account_id   = "eitan-service-${var.env}"
  display_name = "eitan-service KSA Service Account"
}

resource "google_service_account" "notification_service" {
  project      = var.project
  account_id   = "notification-service-${var.env}"
  display_name = "notification-service KSA Service Account"
}

locals {
  app_service_account_emails = toset([
    google_service_account.account_service.email,
    google_service_account.eitan_service.email,
    google_service_account.notification_service.email
  ])
}

resource "google_project_iam_member" "account_service_workload_identity_user" {
  for_each = local.app_service_account_emails
  member   = "serviceAccount:${each.value}"
  role     = "roles/iam.workloadIdentityUser"
}

resource "google_project_iam_member" "account_service_pull_gcr" {
  for_each = local.app_service_account_emails
  member   = "serviceAccount:${each.value}"
  role     = "roles/storage.objectViewer"
}