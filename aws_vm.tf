########################################################################
# Create a VM to test connectivity over the VPN
########################################################################


resource "aws_key_pair" "auth" {
  key_name   = "${var.aws_keypair_name}"
  public_key = "${var.aws_instance_public_key}"
}

resource "aws_instance" "vpn-test-vm-subnet-10-1-1" {

  ami = "ami-8ca83fec"
  instance_type = "t2.micro"
  subnet_id = "${aws_subnet.subnet-10-1-1.id}"

  vpc_security_group_ids = ["${aws_security_group.allow_all_from_gcp.id}", "${aws_security_group.allow_inbound_ssh_and_icmp.id}"]
  associate_public_ip_address = true
  key_name = "${aws_key_pair.auth.key_name}"

  tags {
    Name = "test-vm-subnet-10-1-1"
    Terraform = "yes"
    Project = "${var.project_tag}"
  }
}

resource "aws_instance" "vpn-test-vm-subnet-10-1-2" {

  ami = "ami-8ca83fec"
  instance_type = "t2.micro"
  subnet_id = "${aws_subnet.subnet-10-1-2.id}"

  vpc_security_group_ids = ["${aws_security_group.allow_all_from_gcp.id}", "${aws_security_group.allow_inbound_ssh_and_icmp.id}"]
  associate_public_ip_address = true
  key_name = "${aws_key_pair.auth.key_name}"

  tags {
    Name = "test-vm-subnet-10-1-2"
    Terraform = "yes"
    Project = "${var.project_tag}"
  }
}

resource "aws_security_group" "allow_all_from_gcp" {
  name        = "allow_all"
  description = "Allow all inbound traffic"
  vpc_id = "${aws_vpc.demo-vpc.id}"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [
      "${google_compute_subnetwork.gcp-subnet-10-10-0.ip_cidr_range}",
      "${google_compute_subnetwork.gcp-subnet-10-100-0.ip_cidr_range}"
    ]
  }

  # open outbound access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "demo-sg-allow-all-from-gcp"
    Terraform = "yes"
    Project = "${var.project_tag}"
  }

}

resource "aws_security_group" "allow_inbound_ssh_and_icmp" {
  name = "allow ssh and icmp"
  description = "Allow SSH and ICMP from Internet"
  vpc_id = "${aws_vpc.demo-vpc.id}"

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # open outbound access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "demo-allow-ssh-and-imcp"
    Terraform = "yes"
    Project = "${var.project_tag}"
  }

}