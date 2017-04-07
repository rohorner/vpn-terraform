# An example of how to connect two GCE networks with a VPN
provider "google" {
  account_file = "${file("~/gce/account.json")}"
  project      = "${var.gcp_project}"
  region       = "${var.gcp_region}"
}

# Create the two networks we want to join. They must have seperate, internal
# ranges.
resource "google_compute_network" "tfnetwork" {
  name       = "tfnetwork"
}

resource "google_compute_subnetwork" "tf-subnet" {
  name = "tf-subnet"
  ip_cidr_range = "10.2.1.0/24"
  network = "${google_compute_network.tfnetwork.self_link}"
}

# Create and attach a VPN gateway to the network.
resource "google_compute_vpn_gateway" "gcp-vpn-gateway" {
  name    = "gcp-vpn-gateway"
  network = "${google_compute_network.tfnetwork.self_link}"
  region  = "${var.gcp_region}"
}


# Create an outward facing static IP for each VPN that will be used by the
# other VPN to connect.
resource "google_compute_address" "vpn-static-ip1" {
  name   = "vpn-static-ip1"
  region = "${var.gcp_region}"
}

# Forward IPSec traffic coming into our static IP to our VPN gateway.
resource "google_compute_forwarding_rule" "fr_esp" {
  name        = "fr-esp"
  region      = "${var.gcp_region}"
  ip_protocol = "ESP"
  ip_address  = "${google_compute_address.vpn-static-ip1.address}"
  target      = "${google_compute_vpn_gateway.gcp-vpn-gateway.self_link}"
}

# The following two forwarding rules are used as a part of the IPSec protocol
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

# Define the VPN tunnel toward AWS. Include the local address range that should be sent toward the tunnel.
resource "google_compute_vpn_tunnel" "tunnel1" {
  name               = "tunnel1"
  region             = "${var.gcp_region}"
  peer_ip            = "${aws_vpn_connection.gcp-vpn-connection.tunnel1_address}"
  shared_secret      = "${aws_vpn_connection.gcp-vpn-connection.tunnel1_preshared_key}"
  target_vpn_gateway = "${google_compute_vpn_gateway.gcp-vpn-gateway.self_link}"

  depends_on = ["google_compute_forwarding_rule.fr_udp500",
    "google_compute_forwarding_rule.fr_udp4500",
    "google_compute_forwarding_rule.fr_esp",
  ]
  local_traffic_selector = ["${google_compute_subnetwork.tf-subnet.ip_cidr_range}"]
  remote_traffic_selector = ["${aws_subnet.demo-vpn-subnet.cidr_block}"]
  ike_version = 1
}

# Send traffic destined for the AWS subnet into the tunnel
resource "google_compute_route" "route-to-aws" {
  name       = "route-to-aws"
  network    = "${google_compute_network.tfnetwork.self_link}"
  dest_range = "${aws_subnet.demo-vpn-subnet.cidr_block}"
  priority   = 1000

  next_hop_vpn_tunnel = "${google_compute_vpn_tunnel.tunnel1.self_link}"
}