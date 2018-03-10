/*
terraform {
  backend "s3" {
    bucket  = "ca.ualberta.srv.edrms-contentstore-experiment"
    key     = "staging/contentstore/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}
*/

provider "aws" {
  region = "${var.aws_region}"
}
/*
resource "aws_s3_bucket" "terraform_state" {
  bucket = "ca.ualberta.srv.edrms-contentstore-experiment"

  versioning {
    enabled = true
  }

  lifecycle {
    prevent_destroy = false
  }
  force_destroy = true
}
*/

data "aws_vpc" "main" {
  id = "${var.aws_vpc}"
}






resource "aws_ebs_volume" "ebs_contentstore" {
  availability_zone = "${var.aws_az}"
  size              = 1
  tags {
	SA = "49004"
	Name = "ebs_contentstore_mnt"
	ServiceName = "CDP-EDRMS"
	}
}
