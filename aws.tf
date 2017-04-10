# Build the VPC
resource "aws_vpc" "demo-vpc" {
  cidr_block       = "10.1.0.0/16"

  tags {
    Name = "demo-vpc"
    Terraform = "yes"
  }
}

# Create a subnet in the VPC
resource "aws_subnet" "demo-vpn-subnet" {

  cidr_block = "10.1.1.0/24"
  vpc_id = "${aws_vpc.demo-vpc.id}"
}

# Attach an Internet Gateway to the VPC
resource "aws_internet_gateway" "demo-vpc-igw" {
  vpc_id = "${aws_vpc.demo-vpc.id}"
  tags {
    Name = "demo-vpc-igw"
    Terraform = "yes"
  }
}

# Create a Customer Gateway using the GCP data
resource "aws_customer_gateway" "gcp_gateway" {

  bgp_asn     = 65000
  ip_address  = "${google_compute_address.vpn-static-ip1.address}"
  type        = "ipsec.1"

  tags {
    Name = "gcp-customer-gateway"
    Terraform = "yes"
  }
}

# Create a VPN Gateway
resource "aws_vpn_gateway" "demo-vpn-gw" {
  vpc_id = "${aws_vpc.demo-vpc.id}"

  tags {
    Name = "demo-vpn-gw"
    Terraform = "yes"
  }
}

# Create a VPN tunnel
resource "aws_vpn_connection" "gcp-vpn-connection" {

  customer_gateway_id = "${aws_customer_gateway.gcp_gateway.id}"
  type                = "ipsec.1"
  static_routes_only  = true
  vpn_gateway_id      = "${aws_vpn_gateway.demo-vpn-gw.id}"
}

resource "aws_vpn_connection_route" "route-to-gcp" {
  destination_cidr_block = "${google_compute_subnetwork.tf-subnet.ip_cidr_range}"
  vpn_connection_id = "${aws_vpn_connection.gcp-vpn-connection.id}"
}

# Update the VPC routing table with a next hop to the VPN tunnel
resource "aws_route" "route-to-gcp" {

  route_table_id = "${aws_vpc.demo-vpc.main_route_table_id}"
  destination_cidr_block = "${google_compute_subnetwork.tf-subnet.ip_cidr_range}"
  gateway_id = "${aws_vpn_gateway.demo-vpn-gw.id}"
}

#Update the VPC routing table with a default route
resource "aws_route" "default" {

  route_table_id = "${aws_vpc.demo-vpc.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = "${aws_internet_gateway.demo-vpc-igw.id}"
}

resource "aws_route_table" "default" {
  vpc_id = "${aws_vpc.demo-vpc.main_route_table_id}"

  propagating_vgws = ["${aws_vpn_gateway.demo-vpn-gw.id}"]

  tags {
    Name = "demo-route-table"
    Terraform = "true"
  }
}