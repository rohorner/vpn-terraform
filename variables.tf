# GCE variables

variable "gcp_project" {
  description = "Your project name"
}

variable "gcp_region" {
  description = "The desired region for the first network & VPN and project"
}

variable "gcp_service_account_key" {
  description = "The JSON service account string"
}

# AWS variables

variable "aws_region" {
  description = "The AWS region to deploy into"
}

variable "aws_access_key" {
  description = "Your 20-character AWS Access Key"
}

variable "aws_secret_key" {
  description = "Your 40-character AWS Secret Key"
}

variable "aws_instance_public_key" {
  description = "Public Key Pair string"
}

variable "aws_keypair_name" {
  description = "Name of the key pair to create for VM access"
}

variable "project_tag" {
  description = "Name of the project to tag on each resource"
}