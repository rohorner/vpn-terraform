###################
##  GCP OUTPUTS  ##
###################

output "GCP subnet" {
  value = [
    "${google_compute_subnetwork.gcp-subnet-10-10-0.ip_cidr_range}",
    "${google_compute_subnetwork.gcp-subnet-10-100-0.ip_cidr_range}"
  ]
}

output "GCP Tunnel Endpoint" {
  value = "${google_compute_address.vpn-static-ip1.address}"
}

output "GCP region" {
  value = "${var.gcp_region}"
}

output "GCP Test VM 1 Address" {
  value = [
    "${google_compute_instance.test-vm-10-10-0.network_interface.0.access_config.0.assigned_nat_ip}",
    "${google_compute_instance.test-vm-10-10-0.network_interface.0.address}"
  ]
}

output "GCP Test VM 2 Address" {
  value = [
    "${google_compute_instance.test-vm-10-100-0.network_interface.0.access_config.0.assigned_nat_ip}",
    "${google_compute_instance.test-vm-10-100-0.network_interface.0.address}"
  ]
}


###################
##  AWS OUTPUTS  ##
###################

output "AWS subnet" {
  value = [
    "${aws_subnet.subnet-10-1-1.cidr_block}",
    "${aws_subnet.subnet-10-1-2.cidr_block}",
    ]
}

output "AWS region" {
  value = "${var.aws_region}"
}

output "AWS Tunnel 1 Endpoint" {
  value = "${aws_vpn_connection.gcp-vpn-connection.tunnel1_address}"
}
output "AWS Tunnel 2 Endpoint" {
  value = "${aws_vpn_connection.gcp-vpn-connection.tunnel2_address}"
}

output "AWS Test VM 1 address" {
  value = [
    "${aws_instance.vpn-test-vm-subnet-10-1-1.public_ip}",
    "${aws_instance.vpn-test-vm-subnet-10-1-1.private_ip}"
  ]
}
output "AWS Test VM 2 address" {
  value = [
    "${aws_instance.vpn-test-vm-subnet-10-1-2.public_ip}",
    "${aws_instance.vpn-test-vm-subnet-10-1-2.private_ip}"
  ]
}

output "VPN Tunnel Shared Secret: GCP-AWS" {
  value = "${google_compute_vpn_tunnel.tunnel-1-to-aws.shared_secret}"
}

