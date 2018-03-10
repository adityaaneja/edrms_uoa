provider "aws" {
  region = "${var.aws_region}"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-trusty-14.04-amd64-server-20171115.1"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

}

data "aws_vpc" "main" {
  id = "${var.aws_vpc}"

}


resource "aws_instance" "web" {
  ami           = "${data.aws_ami.ubuntu.id}"
  instance_type = "${var.ec2_instance_type}"
  vpc_security_group_ids = ["${aws_security_group.allow_all.id}"]
  key_name = "AdityaKey"
  tags {
        SA = "49004"
        Name = "ec2_chefserver"
        ServiceName = "CDP-EDRMS"
        }


  subnet_id="${var.aws_subnetid}"
  availability_zone="${var.aws_az}"

 connection {
    type     = "ssh"
    user     = "ubuntu"
    private_key = "${file("${path.module}/AdityaKey.pem")}"
  }


  provisioner "remote-exec" {
    script         = "${path.module}/files/setup.sh"
 }

  provisioner "file" {
    source="files/ec2_rsa.pub"
    destination="/home/ubuntu/.ssh/ec2_rsa.pub"
  }

  provisioner "remote-exec" {
    inline = [ "cat /home/ubuntu/.ssh/ec2_rsa.pub >> /home/ubuntu/.ssh/authorized_keys" ]
  }
  
  provisioner "local-exec" {
    command        = "scp -oStrictHostKeyChecking=no -i /home/terraform/.ssh/ec2_rsa ubuntu@${aws_instance.web.public_dns}:/drop/* ${path.module}/../appnodes/files/"
  }
   



}

resource "aws_security_group" "allow_all" {
  name        = "allow_all"
  description = "Allow all inbound traffic"
  vpc_id      = "${data.aws_vpc.main.id}"

  tags {
        SA = "49004"
        Name = "sg_cheserver_all"
        ServiceName = "CDP-EDRMS"
        }



  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["129.128.123.6/32","10.0.1.0/24"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0","10.0.1.0/24"]
  }

 ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0","10.0.1.0/24"]
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

  egress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
  }


}

 data "template_file" "web" {

    template = "Go to http://$${chefserver} to log into the chef server.Internal ip is $${internalip}"
    vars {
      chefserver = "${aws_instance.web.public_dns}"
      internalip = "${aws_instance.web.private_ip}"
    }
 }

 output "rendered" {
  value = "${data.template_file.web.rendered}"
}



