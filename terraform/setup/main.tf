# Example run
# terraform plan -var "gcp_billing_account_name=My Billing Account FY22" -var 'project_id=cvah-helk-training-fy22' 
# terraform apply -auto-approve -var "gcp_billing_account_name=My Billing Account FY22" -var 'project_id=cvah-helk-training-fy22' 

variable "project_id" {
    type            = string
    default         = "cvah-helk-training"
    # Example: 
    # terraform plan -var 'project_id=cvah-helk-training-fy22' 
    # The display name of the project created will be "Terraform HELK Training"
}

variable "gcp_billing_account_name" {
    type            = string
    default         = "My Billing Account"
    description     = "The billing account name from billing https://console.cloud.google.com/billing."
    # Example:
    # terraform plan -var "gcp_billing_account_name=My Billing Account FY22"
}

provider "google" {
    region          = "us-central1"
    zone            = "us-central1-c"
}

data "google_billing_account" "acct" {
  display_name = var.gcp_billing_account_name
  open         = true
}

resource "google_project_service" "service_api" {
    project                     = var.project_id
    service                     = "serviceusage.googleapis.com"
    disable_on_destroy          = false
}

resource "google_project_service" "compute_api" {
    project                     = var.project_id
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
