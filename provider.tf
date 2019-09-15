provider "aws" {
  version = ">=1.12.0"
  profile = "${var.aws_profile}"
  region  = "${var.aws_region}"
}

terraform {
  backend "s3" {
    bucket  = "mediawikitesting"
    key     = "nvirginia/mediawiki/terraform.tfstate"
    region  = "us-east-1"
    profile = "<Profile_Name>"   // Please provide your Profile Name Here
  }
}

