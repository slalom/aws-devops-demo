#Define Variables
variable "stack_name" {
}

variable "region" {
}

#VPC Variables
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

variable "bastion_instance_type" {
}

variable "bastion_ami_id" {
}

variable "bastion_public_key" {
}

