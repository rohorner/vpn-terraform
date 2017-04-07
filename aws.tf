provider "aws" {
  region     = "${var.aws_region}"
}

variable "public_key_path" {
  default = "~/.ssh/gcp.pub"
}

resource "aws_key_pair" "auth" {
//  key_name   = "${var.key_name}"
  public_key = "${file(var.public_key_path)}"
  key_name = "tf_demo"
//  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC+Om0L8wgOxajMK9dh7zazXoLmh9z/KzinUeO4ZJOPiJFEiugU7QeEeAXKVZWZmsv1RBvQqe7N++VqE505klWjdTHvR7rh6fDHXc2P3DEMKeIti0JEpnu/f2L/3aU+/RQ2am/U+K05nfkoJWX5EC6f/c9sOGLVoO81H2qjRfoHxywn5jyW8EqkuyNH/fg9BgN2uz+TasDjNVk1YU9G19BGA0qPcJOE78by2dbzzslPYuYwN17tgxoEnsExJgTPptX7olfU1ykskp8VewqzJb2TWOX5jR3qHkx7CRuEzEJb8OcM/gElwgsLXy3y4ttA4pxJKCDpEJoVbCkw7JAdJ3Yp rhorner"
}

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
