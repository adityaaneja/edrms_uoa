output "ec2_dns_name" {
  value = "${aws_instance.edrms.*.public_dns}"
}


