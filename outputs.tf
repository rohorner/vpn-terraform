###################
##  GCP OUTPUTS  ##
###################

output "GCP subnet" {
  value = "${google_compute_subnetwork.tf-subnet.ip_cidr_range}"
}

output "GCP VPN Gateway Endpoint" {
  value = "${google_compute_address.vpn-static-ip1.address}"
}

output "GCP VPN Tunnel peer ip" {
  value = "${google_compute_vpn_tunnel.tunnel-to-aws.peer_ip}"
}

output "GCP VPN Tunnel Shared Secret" {
  value = "${google_compute_vpn_tunnel.tunnel-to-aws.shared_secret}"
}

output "GCP region" {
  value = "${var.gcp_region}"
}


###################
##  AWS OUTPUTS  ##
###################

output "AWS subnet" {
  value = "${aws_subnet.demo-vpn-subnet.cidr_block}"
}

output "AWS region" {
  value = "${var.aws_region}"
}

output "AWS Customer Gateway" {
  value = "${aws_customer_gateway.gcp_gateway.ip_address}"
}