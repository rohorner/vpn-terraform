# Set up GCP environment definitions
provider "google" {
//  credentials = "${file("~/gce/account.json")}"
  credentials = "${var.gcp_service_account_key}"
  project      = "${var.gcp_project}"
  region       = "${var.gcp_region}"
}

# Set up AWS environment
provider "aws" {
  region     = "${var.aws_region}"
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
}
