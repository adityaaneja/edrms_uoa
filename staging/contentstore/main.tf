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


data "aws_ebs_volume" "edrms_ebs_volume" {
  most_recent = "true"
  filter {
	name = "tag:Name"
	values = ["ebs_contentstore_mnt"]
	}
}


resource "aws_security_group" "contentstore_sg" {
  name        = "edrms_contentstore_sg"
  vpc_id      = "${data.aws_vpc.main.id}"
  tags {
        SA = "49004"
        Name = "sg_edrms_contenstore"
        ServiceName = "CDP-EDRMS"
        }


}

resource "aws_security_group_rule" "allow_http_outbound" {
  type = "egress"
  security_group_id = "${aws_security_group.contentstore_sg.id}"
  from_port = 80
  to_port = 80
  protocol = "tcp"
  cidr_blocks     = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "allow_https_outbound" {
  type = "egress"
  security_group_id = "${aws_security_group.contentstore_sg.id}"
  from_port = 443
  to_port = 443
  protocol = "tcp"
  cidr_blocks     = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "allow_ssh_inbound" {
  type = "ingress"
  security_group_id = "${aws_security_group.contentstore_sg.id}"
  from_port = 22
  to_port = 22
  protocol = "tcp"
  cidr_blocks     = ["129.128.123.6/32","10.0.1.0/24"]
}

resource "aws_security_group_rule" "allow_rpcbind_inbound" {
  type = "ingress"
  security_group_id = "${aws_security_group.contentstore_sg.id}"
  from_port = 111
  to_port = 111
  protocol = "tcp"
  cidr_blocks     =  ["10.0.1.0/24"]
}

resource "aws_security_group_rule" "allow_nfsserver_inbound" {
  type = "ingress"
  security_group_id = "${aws_security_group.contentstore_sg.id}"
  from_port = 2049
  to_port = 2049
  protocol = "tcp"
  cidr_blocks     =  ["10.0.1.0/24"]
}

resource "aws_security_group_rule" "allow_mountd_inbound" {
  type = "ingress"
  security_group_id = "${aws_security_group.contentstore_sg.id}"
  from_port = 20048
  to_port = 20048
  protocol = "tcp"
  cidr_blocks     =  ["10.0.1.0/24"]
}





resource "aws_volume_attachment" "ebs_contentstore_att" {
  device_name = "/dev/xvdx"
  volume_id   = "${data.aws_ebs_volume.edrms_ebs_volume.id}"
  instance_id = "${aws_instance.edrms_contentstore.id}"
}


resource "aws_instance" "edrms_contentstore" {
  ami               = "${var.aws_ami}"
  availability_zone = "${var.aws_az}"
  instance_type     = "${var.aws_instancetype}"
  vpc_security_group_ids = ["${aws_security_group.contentstore_sg.id}"]
  subnet_id = "${var.aws_subnetid}"
  key_name = "AdityaKey"

  tags {
        SA = "49004"
        Name = "ec2_edrms_contentstore_mnt"
        ServiceName = "CDP-EDRMS"
        }

  user_data = "${file("files/setup_ebs.sh")}"
}

