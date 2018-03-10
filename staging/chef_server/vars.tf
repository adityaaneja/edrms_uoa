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

variable "ec2_instance_type" {
  description = "The instance type for EC2 "
  default     = "t2.medium"
}

variable "aws_subnetid" {
  description = "default subnetid to use"
  default    = "subnet-c9f04081"
}

