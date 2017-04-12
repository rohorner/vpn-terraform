########################################################################
# Create a VM to test connectivity over the VPN
########################################################################

resource "google_compute_instance" "vpn-test-vm" {

  machine_type = "f1-micro"
  name = "vpn-test-vm"
  zone = "us-central1-a"

  "disk" {
    image = "ubuntu-1404-trusty-v20170405"
  }

  network_interface {
    subnetwork = "${google_compute_subnetwork.tf-subnet.name}"
     access_config {
        # Ephemeral
    }
  }

  metadata {
    sshKeys = "ubuntu:${file("~/.ssh/google_compute_engine.pub")}"
   }

  tags = ["${var.project_tag}"]
}

resource "google_compute_firewall" "ssh" {
  name = "tf-ssh-rule"
  network = "${google_compute_network.tfnetwork.id}"
  description = "Allow SSH from anywhere"

  allow {
    protocol = "tcp"
    ports = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "vpn" {
  name = "tf-vpn-firewall"
  network = "default"
  description = "Allow all traffic over VPN"

  allow {
    protocol = "tcp"
  }

  allow {
    protocol = "udp"
  }

  allow {
    protocol = "icmp"
  }

  source_ranges = ["${aws_subnet.demo-vpn-subnet.cidr_block}"]
}