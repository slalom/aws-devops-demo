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
  subnet_private_cidrs  = var.subnet_private_cidrs
  subnet_public_cidrs   = var.subnet_public_cidrs
  availability_zones    = var.availability_zones
  bastion_public_key    = var.bastion_public_key
  bastion_instance_type = var.bastion_instance_type
  bastion_ami_id        = var.bastion_ami_id

  tag_email   = var.tag_email
  tag_manager = var.tag_manager
  tag_market  = var.tag_market
  tag_office  = var.tag_office
}

# Build S3-bucket
module "s3-bucket" {
  source      = "../modules/s3-bucket/"
  bucket_name = "${var.stack_name}-s3"
  tag_email   = "${var.tag_email}"
  tag_manager = "${var.tag_manager}"
  tag_market  = "${var.tag_market}"
  tag_office  = "${var.tag_office}"
}

# # Generate Jenkins Parameters
# module "jenkins" {
#   source  = "../modules/jenkins/"
#   subnets = "${module.vpc.subnets}"
#   tag_email   = "${var.tag_email}"
#   tag_manager = "${var.tag_manager}"
#   tag_market  = "${var.tag_market}"
#   tag_office  = "${var.tag_office}"
# }
# resource "null_resource" "jenkins-deploy" {
#   provisioner "local-exec" {
#     command = "jx install ${module.jenkins.jx_params}"
#   }
# }
