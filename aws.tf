# Build the VPC
resource "aws_vpc" "demo-vpc" {
  cidr_block       = "10.1.0.0/16"

  tags {
    Name = "demo-vpc"
  }
}

# Create a subnet in the VPC
resource "aws_subnet" "demo-vpn-subnet" {

  cidr_block = "10.1.1.0/24"
  vpc_id = "${aws_vpc.demo-vpc.id}"
}

# Create a Customer Gateway using the GCP data
resource "aws_customer_gateway" "gcp_gateway" {

  bgp_asn     = 65000
  ip_address  = "${google_compute_address.vpn-static-ip1.address}"
  type        = "ipsec.1"

  tags {
    Name = "gcp-customer-gateway"
  }
}

# Create a VPN Gateway
resource "aws_vpn_gateway" "vpn-gw" {
  vpc_id = "${aws_vpc.demo-vpc.id}"

  tags {
    Name = "vpn-gw"
  }
}

# Create a VPN tunnel
resource "aws_vpn_connection" "gcp-vpn-connection" {

  customer_gateway_id = "${aws_customer_gateway.gcp_gateway.id}"
  type                = "ipsec.1"
  static_routes_only  = true
  vpn_gateway_id      = "${aws_vpn_gateway.vpn-gw.id}"
}
