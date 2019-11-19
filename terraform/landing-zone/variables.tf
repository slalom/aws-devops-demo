#Define Variables
variable "stack_name" {
}

variable "region" {
}

variable "profile" {
}

variable "vpc_cidr" {
}

variable "subnet_public_cidrs" {
  type = list(string)
}

variable "subnet_private_cidrs" {
  type = list(string)
}

variable "availability_zones" {
  type = list(string)
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
variable "bastion_public_key" {
}

variable "bastion_instance_type" {
}

variable "bastion_ami_id" {
}

