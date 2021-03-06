# Create the GCP network that we want to join
resource "google_compute_network" "gcp-network" {
  name       = "gcp-network"
}

resource "google_compute_subnetwork" "gcp-subnet-10-10-0" {
  name = "gcp-subnet-10-10-0"
  ip_cidr_range = "10.10.0.0/24"
  network = "${google_compute_network.gcp-network.self_link}"
}

resource "google_compute_subnetwork" "gcp-subnet-10-100-0" {
  name = "gcp-subnet-10-100-0"
  ip_cidr_range = "10.100.0.0/24"
  network = "${google_compute_network.gcp-network.self_link}"
}

# Create and attach a VPN gateway to the network
resource "google_compute_vpn_gateway" "gcp-vpn-gateway" {
  name    = "gcp-vpn-gateway"
  network = "${google_compute_network.gcp-network.self_link}"
  region  = "${var.gcp_region}"
}


# Create an external static IP that will be used as the VPN gateway endpoint
resource "google_compute_address" "vpn-static-ip1" {
  name   = "vpn-static-ip1"
  region = "${var.gcp_region}"
}

# Forward three forwarding rules to direct IPSec traffic coming to our static IP toward our VPN gateway
resource "google_compute_forwarding_rule" "fr_esp" {
  name        = "fr-esp"
  region      = "${var.gcp_region}"
  ip_protocol = "ESP"
  ip_address  = "${google_compute_address.vpn-static-ip1.address}"
  target      = "${google_compute_vpn_gateway.gcp-vpn-gateway.self_link}"
}

resource "google_compute_forwarding_rule" "fr_udp500" {
  name        = "fr-udp500"
  region      = "${var.gcp_region}"
  ip_protocol = "UDP"
  port_range  = "500-500"
  ip_address  = "${google_compute_address.vpn-static-ip1.address}"
  target      = "${google_compute_vpn_gateway.gcp-vpn-gateway.self_link}"
}

resource "google_compute_forwarding_rule" "fr_udp4500" {
  name        = "fr-udp4500"
  region      = "${var.gcp_region}"
  ip_protocol = "UDP"
  port_range  = "4500-4500"
  ip_address  = "${google_compute_address.vpn-static-ip1.address}"
  target      = "${google_compute_vpn_gateway.gcp-vpn-gateway.self_link}"
}

# Define the VPN tunnel to AWS. Include the local address range that should be sent toward the tunnel.
resource "google_compute_vpn_tunnel" "tunnel-1-to-aws" {
  name               = "tunnel1"
  region             = "${var.gcp_region}"
  peer_ip            = "${aws_vpn_connection.gcp-vpn-connection.tunnel1_address}"
  shared_secret      = "${aws_vpn_connection.gcp-vpn-connection.tunnel1_preshared_key}"
  target_vpn_gateway = "${google_compute_vpn_gateway.gcp-vpn-gateway.self_link}"

  depends_on = ["google_compute_forwarding_rule.fr_udp500",
    "google_compute_forwarding_rule.fr_udp4500",
    "google_compute_forwarding_rule.fr_esp",
  ]
  local_traffic_selector = [
    "${google_compute_subnetwork.gcp-subnet-10-10-0.ip_cidr_range}",
    "${google_compute_subnetwork.gcp-subnet-10-100-0.ip_cidr_range}"
  ]
  remote_traffic_selector = [
    "${aws_subnet.subnet-10-1-1.cidr_block}",
    "${aws_subnet.subnet-10-1-2.cidr_block}"
  ]
  ike_version = 1
}

# Define the VPN tunnel to AWS. Include the local address range that should be sent toward the tunnel.
resource "google_compute_vpn_tunnel" "tunnel-2-to-aws" {
  name               = "tunnel2"
  region             = "${var.gcp_region}"
  peer_ip            = "${aws_vpn_connection.gcp-vpn-connection.tunnel2_address}"
  shared_secret      = "${aws_vpn_connection.gcp-vpn-connection.tunnel2_preshared_key}"
  target_vpn_gateway = "${google_compute_vpn_gateway.gcp-vpn-gateway.self_link}"

  depends_on = ["google_compute_forwarding_rule.fr_udp500",
    "google_compute_forwarding_rule.fr_udp4500",
    "google_compute_forwarding_rule.fr_esp",
  ]
  local_traffic_selector = [
    "${google_compute_subnetwork.gcp-subnet-10-10-0.ip_cidr_range}",
    "${google_compute_subnetwork.gcp-subnet-10-100-0.ip_cidr_range}"
  ]
  remote_traffic_selector = [
    "${aws_subnet.subnet-10-1-1.cidr_block}",
    "${aws_subnet.subnet-10-1-2.cidr_block}"
  ]
  ike_version = 1
}

# Route traffic destined for the AWS subnet into the tunnel
resource "google_compute_route" "route-to-aws-subnet-10-1-1" {
  name       = "route-to-aws-subnet-10-1-1"
  network    = "${google_compute_network.gcp-network.self_link}"
  dest_range = "${aws_subnet.subnet-10-1-1.cidr_block}"
  priority   = 1000

  next_hop_vpn_tunnel = "${google_compute_vpn_tunnel.tunnel-1-to-aws.self_link}"

}

resource "google_compute_route" "route-to-aws-subnet-10-1-2" {
  name       = "route-to-aws-subnet-10-1-2"
  network    = "${google_compute_network.gcp-network.self_link}"
  dest_range = "${aws_subnet.subnet-10-1-2.cidr_block}"
  priority   = 1000

  next_hop_vpn_tunnel = "${google_compute_vpn_tunnel.tunnel-1-to-aws.self_link}"
}

resource "google_compute_firewall" "allow-all-over-vpn" {
  name = "allow-all-over-vpn"
  network = "${google_compute_network.gcp-network.id}"

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

  source_ranges = ["${aws_subnet.subnet-10-1-1.cidr_block}", "${aws_subnet.subnet-10-1-2.cidr_block}"]
}

resource "google_compute_firewall" "allow-inbound-ssh-icmp" {
  name = "allow-inbound-ssh-icmp"
  network = "${google_compute_network.gcp-network.id}"

  allow {
    protocol = "tcp"
    ports = ["22"]
  }

  allow {
    protocol = "icmp"
  }
}