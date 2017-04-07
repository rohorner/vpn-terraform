# GCE variables

variable "gcp_project" {
  description = "Your project name"
  default = "eng-unfolding-151318"
}

variable "gcp_region" {
  description = "The desired region for the first network & VPN and project"
  default = "us-central1"
}

# AWS variables

variable "aws_region" {
  description = "The AWS region to deploy into"
  default = "us-west-2"
}