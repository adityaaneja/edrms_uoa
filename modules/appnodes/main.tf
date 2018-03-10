provider "aws" {
  region = "${var.aws_region}"
}

/*
data "aws_ami" "centos" {
  most_recent = true

  filter {
    name   = "name"
    values = ["centos/images/hvm-ssd/centos-trusty-14.04-amd64-server-20171115.1"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

}

*/


 data "aws_vpc" "main" {
  id = "${var.aws_vpc}"
}

resource "aws_instance" "lamp" {
#  ami           = "${data.aws_ami.centos.id}"
   ami = "ami-0063927a"
  instance_type = "${var.ec2_instance_type}"
  security_groups = ["lamp_allow_all","nfs"]
  key_name = "mykey"
  count = "${length(var.instancelist)}"
  tags {
    Name = "ChefClient_${element(var.instancelist, count.index)}"
  }
 # subnet_id="${var.aws_subnetid}"
  availability_zone="${var.aws_az}"
 # count = "${length(var.instancelist)}"
  #name = "${element(var.instancelist, count.index)}"
  connection {
    type     = "ssh"
    user     = "centos"
    private_key = "${file("${path.module}/mykey.pem")}"
  }


  provisioner "file" {
    source="files/alfresco.war"
    destination="/home/centos/alfresco.war"
  }

 provisioner "file" {
    source="files/share.war"
    destination="/home/centos/share.war"
  }


provisioner "remote-exec" {
    inline         = [ "sudo yum install nfs-utils -y",
                       "sudo mount 172.31.86.177:/media /media"]
}


   provisioner "chef" {

    environment     = "_default"
    node_name       = "webserver_${element(var.instancelist, count.index)}"
    run_list        = ["edrms"]
    server_url      = "https://${var.chefserverfqdn}/organizations/adityauoa"
    recreate_client = true
    user_name       = "chefadmin"
    user_key        = "${file("${path.module}/files/chefadmin.pem")}"
    version	    = "12.21.20"
    ssl_verify_mode = ":verify_none"
  }


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





/*
module "securitygroups" {
  source = "../../modules/securitygroups"
}
*/
/*
resource "aws_security_group" "lamp_allow_all" {
  name        = "lamp_allow_all"
  description = "Allow all inbound traffic"
  vpc_id      = "${data.aws_vpc.main.id}"
  
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["142.244.161.85/32","142.244.161.39/32","142.244.5.36/32","75.158.126.212/32","172.31.0.0/16"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

 ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
  }

 egress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["172.31.0.0/16"]
  }



  egress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
  }

}


resource "aws_security_group" "contentstore_clientsg" {
  name        = "edrms_contentstore_clientsg"
  description = "Allow all inbound traffic"
  vpc_id      = "${data.aws_vpc.main.id}"


  egress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = ["172.31.0.0/16"]
  }

    egress {
    from_port   = 111
    to_port     = 111
    protocol    = "tcp"
    cidr_blocks = ["172.31.0.0/16"]
  }

  egress {
    from_port   = 20048
    to_port     = 20048
    protocol    = "tcp"
    cidr_blocks = ["172.31.0.0/16"]
  }


}
*/



