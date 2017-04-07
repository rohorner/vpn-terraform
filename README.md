# vpn-terraform
Terraform code to build VPNs between VSphere, AWS, and GCP.

Currently only the AWS-GCP VPN code is working.

***This README is currently missing a lot of info. Ping Rob if you want detailed instructions or a walkthrough on how to use it.***

## Getting Started

You must have valid SSH keys in order to remotely access the test VMs in each cloud.

Begin by creating a new SSH key pair. We'll call this one terraform.

```
$ ssh-keygen
Generating public/private rsa key pair.
Enter file in which to save the key (/Users/myuser/.ssh/id_rsa): /Users/myuser/.ssh/terraform
```

### Set up your AWS credentials
Create environment variables for your AWS Access Key and Secret Key.

```
$ export AWS_ACCESS_KEY_ID=[your 20-character AWS access key]
$ export AWS_SECRET_KEY=[your 40-character AWS secret key]
```
### Set up your GCP credentials
If you haven't already, download your GCP credentials JSON file:

In the GCP Console, select the "IAM & Admin" menu item, then "Service Accounts".
To the right of the service account that you wish to use, pull down the options
menu and select "Create Key". Select "JSON" as the Key Type and hit "CREATE". GCP will
create the file and automatically download it to your computer.

Store the downloaded file as `~/gce/account.json`.



## Building the AWS to GCP VPN connection

Clone the repo to your server and execute terraform.

```
$ git clone git@github.com:trace3-cts/vpn-terraform.git
$ cd vpn-terraform
$ terraform apply
```
