resource "google_compute_firewall" "allow-all-over-vpn" {
  name = "allow-all-over-vpn"
  network = "${google_compute_network.tf-network.id}"

  allow {
    protocol = "tcp"
    ports = ["0-65535"]
  }

  allow {
    protocol = "udp"
    ports = ["0-65535"]
  }

  allow {
    protocol = "icmp"
  }

  source_ranges = ["${aws_subnet.demo-vpn-subnet.cidr_block}"]
}

resource "google_compute_firewall" "allow-inbound-ssh-icmp" {
  name = "allow-inbound-ssh-icmp"
  network = "${google_compute_network.tf-network.id}"

  allow {
    protocol = "tcp"
    ports = ["22"]
  }

  allow {
    protocol = "icmp"
  }
}