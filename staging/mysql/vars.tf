variable "aws_region" {
  description = "The name aws region to use "
  default     = "us-west-2"
}

variable "aws_az" {
  description = "The name of the AZ to use "
  default     = "us-west-2a"
}


variable "aws_vpc" {
  description = "The name of the vpc to use "
  default     = "vpc-5d531e3b"
}

variable "aws_subnetid" {
  description = "default subnetid to use"
  default    = "subnet-c9f04081"
}

variable "aws_subnetid_private" {
  description = "default private subnetid to use"
  default    = "subnet-ea09998c"
}

variable "aws_ami" {
  description = "default ami to use. dcos-centos7-201701121536"
  default    = "ami-06f84566"
}


variable "aws_instancetype" {
  description = "default instance type to use"
  default    = "t2.micro"
}


