provider "google" {
  project = "savvy-bay-362807"
  region  = "europe-west1"
  zone    = "europe-west1-d"
}

resource "google_compute_instance" "terraform" {
  name         = "terraform"
  machine_type = "e2-micro"
  boot_disk {
    initialize_params {
      image = "projects/centos-cloud/global/images/centos-stream-9-v20240919"
    }
  }
  network_interface {
    network = "default"
    access_config {
    }
  }
}

