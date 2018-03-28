variable "aws_region" {
  description = "The AWS region to use"
  default     = "us-west-2"
}

variable "aws_vpc" {
  description = "The name of the vpc to use "
  default     = "vpc-5d531e3b"
}

variable "aws_az" {
  description = "The name of the AZ to use "
  default     = "us-west-2a"
}

variable "aws_subnetid" {
  description = "The name of the subnetid to use "
  default     = "subnet-c9f04081"
}


variable "aws_ami" {
  description = "default ami to use. dcos-centos7-201701121536"
  default    = "ami-6ec55b16"
}


variable "ec2_instance_type" {
  description = "The instance type for EC2 "
  default     = "t2.small"
}

variable "chefserver" {
  description = "IP Address of the Chef server "
  default     = "172.31.88.48"
}

variable "chefserverfqdn" {
  description = "fqdn of the Chef server "
  default     = "localhost.localdomain"
}

variable "instancelist" {
  description = "Count of the Chef nodes"
  type = "list"
  default = ["edrms_node1"]
}

