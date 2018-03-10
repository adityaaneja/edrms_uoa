 data "aws_vpc" "main" {
  id = "${var.aws_vpc}"
}


resource "aws_security_group" "lamp_allow_all" {
  name        = "lamp_allow_all"
  description = "Allow all inbound traffic"
  vpc_id      = "${data.aws_vpc.main.id}"
}

resource "aws_security_group_rule" "allow_inbound_http" {
	type = "ingress"
	security_group_id = "${aws_security_group.lamp_allow_all.id}"
	from_port = 80
	to_port = 80
	protocol = "tcp"
	cidr_blocks = ["0.0.0.0/0"]
  }

  
resource "aws_security_group_rule" "allow_outbound_http" {
        type = "egress"
        security_group_id = "${aws_security_group.lamp_allow_all.id}"
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
  }

resource "aws_security_group_rule" "allow_inbound_https" {
        type = "ingress"
        security_group_id = "${aws_security_group.lamp_allow_all.id}"
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
  }


resource "aws_security_group_rule" "allow_outbound_https" {
        type = "egress"
        security_group_id = "${aws_security_group.lamp_allow_all.id}"
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
  }

resource "aws_security_group_rule" "allow_inbound_ssh" {
        type = "ingress"
        security_group_id = "${aws_security_group.lamp_allow_all.id}"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["142.244.161.85/32","142.244.161.39/32","142.244.5.51/32","75.158.126.212/32","172.31.0.0/16"]

  }


resource "aws_security_group_rule" "allow_outbound_ssh" {
        type = "egress"
        security_group_id = "${aws_security_group.lamp_allow_all.id}"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["172.31.0.0/16"]
  }


