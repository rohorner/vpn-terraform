# vpn-terraform
Terraform code to build VPNs between VSphere, AWS, and GCP.

**Currently only the AWS-GCP VPN code is working.**

## Getting Started

### Clone the repo
Clone the repo to your server.

```
$ git clone git@github.com:trace3-cts/vpn-terraform.git
$ cd vpn-terraform
```

### Set up your cloud credentials
If you haven't already, download your GCP credentials JSON file:

In the GCP Console, select the "IAM & Admin" menu item, then "Service Accounts".
To the right of the service account that you wish to use, pull down the options
menu and select "Create Key". Select "JSON" as the Key Type and hit "CREATE". GCP will
create the file and automatically download it to your computer.

Using `terraform.tfvars.example`, create a `terraform.tfvars` file in the root of the project directory.
Include the GCP region, zone, and service account key JSON string that you downloaded from GCP. Also include the AWS region and your Access and Secret Keys.

**DO NOT SHARE THIS FILE** unless you want an extremely high credit card bill next month.

```gcp_project = "your-gcp-project-id"
gcp_region = "us-central1"
gcp_zones = ["us-central1-a", "us-central1-b", "us-central1-c"]
service_account_key = <<SERVICE_ACCOUNT_KEY
{
  "type": "service_account",
  "project_id": "your-gcp-project-id",
  "private_key_id": "another-gcp-private-key",
  "private_key": "-----BEGIN PRIVATE KEY-----another gcp private key-----END PRIVATE KEY-----\n",
  "client_email": "me@example.com",
  "client_id": "11111111111111",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://accounts.google.com/o/oauth2/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/"
}
SERVICE_ACCOUNT_KEY

aws_region = "us-west-2"
```

Update variable default "shared_credentials_file" in variables.tf to point to your local AWS credentials file. On Mac this is usually located at /Users/[username]/.aws/credentials

### Building the AWS to GCP VPN connection

Execute `terraform apply` to create the environment. In about five minutes you should
have a working VPN connection between your two clouds. Once complete, TF will output the following information:
```
Outputs:

AWS Test VM address = <IPv4 of the AWS test VM>
AWS Tunnel 1 Endpoint = <IPv4 of the AWS tunnel endpoint>
AWS region = <AWS region of the VPC>
AWS subnet = <AWS VPN subnetwork CIDR where the VPN terminates>

GCP Tunnel Endpoint = <IPv4 of the GCP tunnel endpoint>
GCP VPN Tunnel Shared Secret = <shared secret, aka, preshared key of the IPSec tunnel>
GCP region = <GCP region of the network>
GCP subnet = <GCP network CIDR where the VPN terminates>
```
