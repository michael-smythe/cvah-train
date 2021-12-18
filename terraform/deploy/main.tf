variable "project_id" {
    type                        = string
    default                     = "cvah-helk-training"
}

variable "elk_count" {
    type                        = number
    default                     = 1
}

provider "google" {
    project                     = var.project_id
    region                      = "us-central1"
    zone                        = "us-central1-c"
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

data "google_compute_network" "default" {
    name                        = "default"
} 

resource "google_compute_firewall" "rules" {
  depends_on                    = [google_project_service.compute_api]
  name                          = "my-firewall-rules"
  network                       = data.google_compute_network.default.self_link
  description                   = "Creates firewall rule targeting tagged instances"

  allow {
    protocol                    = "tcp"
    ports                       = ["80", "443", "5601", "9200", "9600", "9300"]
  }

  source_tags                   = ["elk"]
}

resource "google_compute_instance" "elk" {
    depends_on                    = [google_project_service.compute_api]
    count                       = var.elk_count
    depends_on                  = [google_compute_firewall.rules]
    name			            = "elk-${count.index}"
    machine_type                = "n1-standard-8"

    tags                        = ["elk","http-server","https-server"]

    boot_disk {
        initialize_params {
            image               = "${var.project_id}/cvah-elk-train"
        }
    }

    network_interface {
        network                 = "default"

        # This line ensures an ephemeral public IP is allocated to this machine
        access_config {}
    }

    scheduling {
        preemptible             = true
        automatic_restart       = false
    }
} 

output "public_ip" {
    value = [google_compute_instance.elk.*.network_interface.0.access_config.0.nat_ip]
}
