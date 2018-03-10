provider "aws" {
  region = "${var.aws_region}"
}


 data "aws_vpc" "main" {
  id = "${var.aws_vpc}"
}

data "aws_instance" "chefserver" {
  filter {
        name = "tag:Name"
        values = ["ec2_chefserver"]
        }
}


data "aws_db_instance" "edrms_database" {
        db_instance_identifier = "edrms-db"
}


data "aws_instance" "edrms_contentstore" {
  filter {
        name = "tag:Name"
        values = ["ec2_edrms_contentstore_mnt"]
        }
}





resource "aws_instance" "edrms" {
  ami           = "${var.aws_ami}"
  instance_type = "${var.ec2_instance_type}"
  vpc_security_group_ids = ["${aws_security_group.edrms_allow_all.id}","${aws_security_group.edrms_contentstore_clientsg.id}"]
  key_name = "AdityaKey"
  count = "${length(var.instancelist)}"
  subnet_id="${var.aws_subnetid}"
  availability_zone="${var.aws_az}"
 # count = "${length(var.instancelist)}"
  #name = "${element(var.instancelist, count.index)}"

   tags {
        SA = "49004"
        Name = "ec2_edrms_appnode"
        ServiceName = "CDP-EDRMS"
        }


  connection {
    type     = "ssh"
    user     = "centos"
    private_key = "${file("${path.module}/AdityaKey.pem")}"
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
                       "sudo mount ${data.aws_instance.edrms_contentstore.private_ip}:/mnt /mnt"]
  }


   provisioner "chef" {

    environment     = "_default"
    node_name       = "webserver_${element(var.instancelist, count.index)}"
    run_list        = ["edrms"]
    server_url      = "https://${data.aws_instance.chefserver.public_dns}/organizations/adityauoa"
    recreate_client = true
    user_name       = "chefadmin"
    user_key        = "${file("${path.module}/files/chefadmin.pem")}"
    version	    = "12.21.20"
    ssl_verify_mode = ":verify_none"
    attributes_json = <<-EOF
       {
	"database_address": "${data.aws_db_instance.edrms_database.address}",
        "database_port": "${data.aws_db_instance.edrms_database.port}"
       }
    EOF
    
  }



}


resource "aws_security_group" "edrms_allow_all" {
  name        = "edrms_allow_all"
  description = "Allow all inbound traffic"
  vpc_id      = "${data.aws_vpc.main.id}"

  tags {
        SA = "49004"
        Name = "sg_edrmsappnode_all"
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
    cidr_blocks = ["0.0.0.0/0"]
  }

 ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
  }

 egress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    cidr_blocks     = ["10.0.1.0/24"]
  }


 egress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.1.0/24"]
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

resource "aws_security_group" "edrms_contentstore_clientsg" {
  name        = "edrms_contentstore_clientsg"
  description = "Allow all inbound traffic"
  vpc_id      = "${data.aws_vpc.main.id}"
  
  tags {
        SA = "49004"
        Name = "sg_edrmscontenstore"
        ServiceName = "CDP-EDRMS"
        }


  egress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = ["10.0.1.0/24"]
  }

    egress {
    from_port   = 111
    to_port     = 111
    protocol    = "tcp"
    cidr_blocks = ["10.0.1.0/24"]
  }

  egress {
    from_port   = 20048
    to_port     = 20048
    protocol    = "tcp"
    cidr_blocks = ["10.0.1.0/24"]
  }


}




