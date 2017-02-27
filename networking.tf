resource "google_compute_network" "cr460" {
  name                    = "cr460"
  auto_create_subnetworks = "false"
}

resource "google_compute_subnetwork" "public" {
  name          = "public"
  ip_cidr_range = "172.16.1.0/24"
  network       = "${google_compute_network.cr460.self_link}"
  region        = "us-east1"
}

resource "google_compute_subnetwork" "workload" {
  name          = "workload"
  ip_cidr_range = "10.0.1.0/24"
  network       = "${google_compute_network.cr460.self_link}"
  region        = "us-east1"
}

resource "google_compute_subnetwork" "backend" {
  name          = "backend"
  ip_cidr_range = "192.168.1.0/24"
  network       = "${google_compute_network.cr460.self_link}"
  region        = "us-east1"
}

resource "google_compute_firewall" "web" {
  name    = "web"
  network = "${google_compute_network.cr460.name}"
    allow {
    protocol = "tcp"
    ports    = ["80"]
  }
}
resource "google_compute_firewall" "https" {
  name    = "https"
  network = "${google_compute_network.cr460.name}"
  allow {
    protocol = "tcp"
    ports    = ["443"]
  }
}
resource "google_compute_firewall" "ssh" {
  name    = "ssh"
  network = "${google_compute_network.cr460.name}"
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_ranges = ["192.168.1.0/24","10.0.1.0/24","172.16.1.0/24"]
  }
  resource "google_compute_firewall" "etcd1" {
    name    = "etcd1"
    network = "${google_compute_network.cr460.name}"
    allow {
      protocol = "tcp"
      ports    = ["2379","2380"]
    }
    source_ranges = ["192.168.1.0/24","10.0.1.0/24"]
    }
    resource "google_compute_firewall" "etcd2" {
      name    = "etcd2"
      network = "${google_compute_network.cr460.name}"
      allow {
        protocol = "tcp"
        ports    = ["2379","2380"]
      }
      source_ranges = ["192.168.1.0/24","172.16.1.0/24"]
      }
  resource "google_dns_managed_zone" "mehinfo1" {
  name        = "mehinfo1"
  dns_name    = "mehinfo1.cr490lab.com."
  description = "Production DNS zone"
}
resource "google_dns_record_set" "instance1" {
  name = "www.jump.mehinfo1.cr490lab.com."
  type = "A"
  ttl  = 300

  managed_zone = "mehinfo1"

  rrdatas = ["${google_compute_instance.instance1.network_interface.0.access_config.0.assigned_nat_ip}"]
}
resource "google_dns_record_set" "instance2" {
  name = "www.vault.mehinfo1.cr490lab.com."
  type = "A"
  ttl  = 300

  managed_zone = "mehinfo1"

  rrdatas = ["${google_compute_instance.instance2.network_interface.0.access_config.0.assigned_nat_ip}"]
}
