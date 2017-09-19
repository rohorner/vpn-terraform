terraform {
    backend s3 {
        bucket = "terraform-states-rhorner"
        key    = "vpn-terraform.tfstate"
        region = "us-west-2"
  }
}
