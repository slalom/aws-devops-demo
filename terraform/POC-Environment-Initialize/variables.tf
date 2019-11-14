#Define Variables
variable "stack_name" {}
variable "region" {}

variable "vpc_cidr" {}

variable "subnet_public_cidrs" {
  type = "list"
}

variable "subnet_private_cidrs" {
  type = "list"
}

variable "availability_zones" {
  type = "list"
}

#Tags
variable "tag_manager" {}
variable "tag_market" {}
variable "tag_office" {}
variable "tag_email" {}

#Bastion Variables
variable "bastion_key_name" {}
variable "bastion_instance_type" {
  default = "c5.large"
}
variable "bastion_ami_id" {
  default = "ami-07a0c6e669965bb7c"
}
