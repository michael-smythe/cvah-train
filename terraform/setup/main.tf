variable "project_id" {
    type            = string
    default         = "cvah-helk-training"
}

provider "google" {
    region          = "us-central1"
    zone            = "us-central1-c"
}

data "google_billing_account" "acct" {
  display_name = "My Billing Account"
  open         = true
}

resource "google_project_service" "service_api" {
   service                      = "serviceusage.googleapis.com"
   disable_on_destroy           = false
}

resource "google_project_service" "compute_api" {
    depends_on 			        = [google_project_service.service_api]
    service 			        = "compute.googleapis.com"
    disable_on_destroy          = false
}

resource "google_project" "cvah" {
    name            = "Terraform HELK Training"
    project_id      = var.project_id 

    billing_account = data.google_billing_account.acct.id
}

output "project-id" {
    value           = google_project.cvah.project_id
}
