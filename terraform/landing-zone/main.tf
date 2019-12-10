# Initialize AWS Environment
# This plan builds, VPC, subnet, ssh_key, s3-bucket, and required resources

#Set Provider
provider "aws" {
  region  = var.region
  profile = var.profile
}

#Build VPC, Route Table, Internet Gateway, Bastion, Subnets, etc.
module "vpc" {
  source                = "../modules/vpc/"
  stack_name            = var.stack_name
  region                = var.region
  vpc_cidr              = var.vpc_cidr
  subnet_private_cidr_1 = var.subnet_private_cidr_1
  subnet_private_cidr_2 = var.subnet_private_cidr_2
  subnet_public_cidr_1  = var.subnet_public_cidr_1
  subnet_public_cidr_2  = var.subnet_public_cidr_2
  availability_zone_1   = var.availability_zone_1
  availability_zone_2   = var.availability_zone_2
  bastion_public_key    = var.ssh_public_key
  bastion_instance_type = var.bastion_instance_type
  bastion_ami_id        = var.bastion_ami_id

  build_nat_gateway = var.build_nat_gateway

  tag_email   = var.tag_email
  tag_manager = var.tag_manager
  tag_market  = var.tag_market
  tag_office  = var.tag_office
}

# Build S3-bucket
module "s3-bucket" {
  source      = "../modules/s3-bucket/"
  bucket_name = "${var.stack_name}-lambda-s3"
  tag_email   = var.tag_email
  tag_manager = var.tag_manager
  tag_market  = var.tag_market
  tag_office  = var.tag_office
}


