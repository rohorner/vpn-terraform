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
