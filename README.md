# Terraform MediaWiki Deployment #

## This terraform code will deploy following resources. ##
	1) VPC
	2) Subnet
	3) Routingtable
	4) IGW
	5) NATGateway
	6) SecurityGroup
	7) Classic LoadBalancer
	8) MediaWiki Webserver - 2
	9) MediaWiki Database Server - 1
	10) Ansible Playbook is used to Deploy HTTP, PHP and download MediaWiki TAR File	
	11) Terraform Connection with PrivateKey and Provisioner is used to push Ansible-Playbook and execute
	12) Terraform User-Data is used to deploy MariaDB on MediaWiki Database Server
	13) Terraform State File is being saved in AWS S3 Bucket with Versioning Enabled. So that, All the previous TFSTATE will be saved.

# Pre-requisite #

### It is mandatory to setup the following before trigger terraform init. ###
	> IAM User Should be created to access EC2FullAccess, S3FullAccess, VPCFullAccess.
	> AWS Configure Should be configured with ACCESS_KEY, SECRET_KEY.
	> S3BUCKETNAME = "mediawikitesting" Should be created on AWS Account.

Configuration to save TFSTATE in S3 Bucket.

	terraform {
	  backend "s3" {
	    bucket  = "mediawikitesting"
	    key     = "nvirginia/mediawiki/terraform.tfstate"
	    region  = "us-east-1"
	    profile = "<Profile_Name>"   # Provide your Profile Name Here
	  }
	}

Steps to run this project:

In your Terminal, cd to instance folder. Run:
terraform init
terraform plan
terraform apply
Use the terraform.tfvars file to provide variable of Terraform.

