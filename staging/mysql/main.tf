/*
terraform {
  backend "s3" {
    bucket  = "mysql-aamyuser"
    key     = "stage/services/mysql-cluster/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}
*/

provider "aws" {
  region = "${var.aws_region}"
}

 data "aws_vpc" "main" {
  id = "${var.aws_vpc}"
}


/*
resource "aws_s3_bucket" "terraform_state" {
  bucket = "mysql-aamyuser"

  versioning {
    enabled = true
  }

  lifecycle {
    prevent_destroy = false
  }
}
*/
/*
resource "aws_db_instance" "example" {
  engine            = "mysql"
  allocated_storage = 10
  instance_class    = "db.t2.micro"
  name              = "example_database"
  username          = "admin"
  password          = "${var.db_password}"
}
*/

resource "aws_db_instance" "alfresco" {
  identifier	       = "edrms-db"
  allocated_storage    = 10
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "5.6"
  instance_class       = "db.t2.micro"
  name                 = "alfresco"
  username             = "alfresco"
  password             = "alfresco2251"
  db_subnet_group_name = "edrmsdbsubnetgroup"
  parameter_group_name = "default.mysql5.6"
  availability_zone     = "${var.aws_az}"
  publicly_accessible  = false 
  vpc_security_group_ids = ["${aws_security_group.database_sg.id}"]
  skip_final_snapshot = true
  tags {
        SA = "49004"
        Name = "rds_edrms_mysql"
        ServiceName = "CDP-EDRMS"
  }
 
}

resource "aws_security_group" "database_sg" {
  name        = "database_sg"
  description = "Allow all inbound traffic to Mysql"
  vpc_id      = "${data.aws_vpc.main.id}"
  
  tags {
        SA = "49004"
        Name = "sg_edrmsrds_mysql"
        ServiceName = "CDP-EDRMS"
  }


  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["10.0.1.0/24"]
  }

}


resource "aws_db_subnet_group" "edrms_db_subnetgroup" {
  name       = "edrmsdbsubnetgroup"
  subnet_ids = ["${var.aws_subnetid}", "${var.aws_subnetid_private}"]

  tags {
        SA = "49004"
        Name = "rdssubgroup_edrms_mysql"
        ServiceName = "CDP-EDRMS"
        }
}
