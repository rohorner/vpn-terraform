# Set up GCP environment definitions
provider "google" {
//  credentials = "${file("~/gce/account.json")}"
  credentials = "${var.gcp_service_account_key}"
  project      = "${var.gcp_project}"
  region       = "${var.gcp_region}"
}

# Provider Settings
provider "aws" {
  shared_credentials_file = "${var.shared_credentials_file}"
  region                  = "${var.aws_region}"
  profile                 = "${var.profile}"
}
