# Build the VPC
resource "aws_vpc" "demo-vpc" {
  cidr_block       = "10.1.0.0/16"

  tags {
    Name = "demo-vpc"
    Terraform = "yes"
    Project = "${var.project_tag}"
  }
}

# Create a subnet in the VPC
resource "aws_subnet" "subnet-10-1-1" {

  cidr_block = "10.1.1.0/24"
  vpc_id = "${aws_vpc.demo-vpc.id}"
  map_public_ip_on_launch = true

  tags {
        Project = "${var.project_tag}"
  }
}
# Create a subnet in the VPC
resource "aws_subnet" "subnet-10-1-2" {

  cidr_block = "10.1.2.0/24"
  vpc_id = "${aws_vpc.demo-vpc.id}"
  map_public_ip_on_launch = true

  tags {
        Project = "${var.project_tag}"
  }
}

# Attach an Internet Gateway to the VPC
resource "aws_internet_gateway" "demo-vpc-igw" {
  vpc_id = "${aws_vpc.demo-vpc.id}"

  tags {
    Name = "demo-vpc-igw"
    Terraform = "yes"
    Project = "${var.project_tag}"
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
    Project = "${var.project_tag}"
  }
}

# Create a VPN Gateway
resource "aws_vpn_gateway" "demo-vpn-gw" {
  vpc_id = "${aws_vpc.demo-vpc.id}"

  tags {
    Name = "demo-vpn-gw"
    Terraform = "yes"
    Project = "${var.project_tag}"
  }
}

# Create a VPN tunnel
resource "aws_vpn_connection" "gcp-vpn-connection" {

  customer_gateway_id = "${aws_customer_gateway.gcp_gateway.id}"
  type                = "ipsec.1"
  static_routes_only  = true
  vpn_gateway_id      = "${aws_vpn_gateway.demo-vpn-gw.id}"

  tags {
    Name = "demo-gcp-vpn-connection"
    Project = "${var.project_tag}"
  }
}

resource "aws_vpn_connection_route" "route-to-gcp-10-2-1" {
  destination_cidr_block = "${google_compute_subnetwork.gcp-subnet-10-10-0.ip_cidr_range}"
  vpn_connection_id = "${aws_vpn_connection.gcp-vpn-connection.id}"
}

resource "aws_vpn_connection_route" "route-to-gcp-10-2-2" {
  destination_cidr_block = "${google_compute_subnetwork.gcp-subnet-10-100-0.ip_cidr_range}"
  vpn_connection_id = "${aws_vpn_connection.gcp-vpn-connection.id}"
}

resource "aws_route_table" "demo-route-table" {
  vpc_id = "${aws_vpc.demo-vpc.id}"

  propagating_vgws = ["${aws_vpn_gateway.demo-vpn-gw.id}"]

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.demo-vpc-igw.id}"
  }

  tags {
    Name = "demo-route-table"
    Terraform = "true"
    Project = "${var.project_tag}"
  }
}

# Associate the newly created route table to the VPC
resource "aws_main_route_table_association" "a" {
  vpc_id = "${aws_vpc.demo-vpc.id}"
  route_table_id = "${aws_route_table.demo-route-table.id}"
}