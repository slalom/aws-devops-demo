#Define Variables
variable "stack_name" {
}

variable "region" {
}

variable "profile" {
}

variable "ssh_public_key" {
}

variable "build_nat_gateway" {
}

variable "vpc_cidr" {
}

variable "subnet_public_cidr_1" {
}

variable "subnet_public_cidr_2" {
}

variable "subnet_private_cidr_1" {
}

variable "subnet_private_cidr_2" {
}

variable "availability_zone_1" {
}

variable "availability_zone_2" {
}

#Tags
variable "tag_manager" {
}

variable "tag_market" {
}

variable "tag_office" {
}

variable "tag_email" {
}

#Bastion Variables

variable "bastion_instance_type" {
}

variable "bastion_ami_id" {
}

#Jenkins Variables
variable "kms_bucket" {
}
