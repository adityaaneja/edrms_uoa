 data "aws_vpc" "main" {
  id = "${var.aws_vpc}"
}


resource "aws_security_group" "nfs" {
  name        = "nfs"
  description = "Rule pertaining to NFS"
  vpc_id      = "${data.aws_vpc.main.id}"
}


resource "aws_security_group_rule" "allow_outbound_nfs" {
        type = "egress"
        security_group_id = "${aws_security_group.nfs.id}"
        from_port = 2049
        to_port = 2049
        protocol = "tcp"
        cidr_blocks = ["172.31.0.0/16"]

  }


resource "aws_security_group_rule" "allow_outbound_portmapper" {
        type = "egress"
        security_group_id = "${aws_security_group.nfs.id}"
        from_port = 111
        to_port = 111
        protocol = "tcp"
        cidr_blocks = ["172.31.0.0/16"]
  }

resource "aws_security_group_rule" "allow_outbound_mountd" {
        type = "egress"
        security_group_id = "${aws_security_group.nfs.id}"
        from_port = 20048
        to_port = 20048
        protocol = "tcp"
        cidr_blocks = ["172.31.0.0/16"]
  }



