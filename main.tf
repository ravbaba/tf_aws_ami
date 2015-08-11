variable "region" {}

output "ami_id" {
	value = "${lookup(var.all_amis, var.region)}"
}
