# Create the GCP network that we want to join
resource "google_compute_network" "tf-network" {
  name       = "tf-network"
}

resource "google_compute_subnetwork" "tf-subnet" {
  name = "tf-subnet"
  ip_cidr_range = "10.2.1.0/24"
  network = "${google_compute_network.tf-network.self_link}"
}

# Create and attach a VPN gateway to the network
resource "google_compute_vpn_gateway" "gcp-vpn-gateway" {
  name    = "gcp-vpn-gateway"
  network = "${google_compute_network.tf-network.self_link}"
  region  = "${var.gcp_region}"
}


# Create an external static IP that will be used as the VPN gateway endpoint
resource "google_compute_address" "vpn-static-ip1" {
  name   = "vpn-static-ip1"
  region = "${var.gcp_region}"
}

resource "google_compute_router" "cloud-router" {
  name = "cloud-router"
  network = "${google_compute_network.tf-network.name}"
  bgp {
    asn = "${var.gcp_bgp_asn}"
  }

}

# Create Cloud Router interface and BGP peer for first AWS VPN link
resource "google_compute_router_interface" "interface-aws-1" {
  name = "interface-aws-1"
  router     = "${google_compute_router.cloud-router.name}"
  ip_range   = "${aws_vpn_connection.gcp-vpn-connection.tunnel1_cgw_inside_address}/30"
  vpn_tunnel = "${google_compute_vpn_tunnel.tunnel1-to-aws.name}"
}

resource "google_compute_router_peer" "aws_vpn_peer-1" {
  name                      = "aws-vpn-peer-1"
  router                    = "${google_compute_router.cloud-router.name}"
  peer_ip_address           = "${aws_vpn_connection.gcp-vpn-connection.tunnel1_vgw_inside_address}"
  peer_asn                  = 7224
  advertised_route_priority = 100
  interface                 = "${google_compute_router_interface.interface-aws-1.id}"
}

# Create Cloud Router interface and BGP peer for second AWS VPN link

resource "google_compute_router_interface" "interface-aws-2" {
  name = "interface-aws-2"
  router     = "${google_compute_router.cloud-router.name}"
  ip_range   = "${aws_vpn_connection.gcp-vpn-connection.tunnel2_cgw_inside_address}/30"
  vpn_tunnel = "${google_compute_vpn_tunnel.tunnel2-to-aws.name}"
}

resource "google_compute_router_peer" "aws_vpn_peer-2" {
  name                      = "aws-vpn-peer-2"
  router                    = "${google_compute_router.cloud-router.name}"
  peer_ip_address           = "${aws_vpn_connection.gcp-vpn-connection.tunnel2_vgw_inside_address}"
  peer_asn                  = 7224
  advertised_route_priority = 100
  interface                 = "${google_compute_router_interface.interface-aws-2.id}"
}

# Define the VPN tunnels to AWS. Include the local address range that should be sent toward the tunnel.
resource "google_compute_vpn_tunnel" "tunnel1-to-aws" {
  name               = "tunnel1-to-aws"
  peer_ip            = "${aws_vpn_connection.gcp-vpn-connection.tunnel1_address}"
  shared_secret      = "${aws_vpn_connection.gcp-vpn-connection.tunnel1_preshared_key}"
  target_vpn_gateway = "${google_compute_vpn_gateway.gcp-vpn-gateway.self_link}"

  ike_version = 1

  router             = "${google_compute_router.cloud-router.name}"
}

resource "google_compute_vpn_tunnel" "tunnel2-to-aws" {
  name               = "tunnel2-to-aws"
  peer_ip            = "${aws_vpn_connection.gcp-vpn-connection.tunnel2_address}"
  shared_secret      = "${aws_vpn_connection.gcp-vpn-connection.tunnel2_preshared_key}"
  target_vpn_gateway = "${google_compute_vpn_gateway.gcp-vpn-gateway.self_link}"

  ike_version = 1

  router             = "${google_compute_router.cloud-router.name}"
}

