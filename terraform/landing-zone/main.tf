# Initialize AWS Environment
# This plan builds, VPC, subnet, ssh_key, s3-bucket, and required resources

#Build VPC, Route Table, Internet Gateway, Bastion, Subnets, etc.
module "vpc" {
  region = "${var.region}"
  source = "../modules/vpc/"

  tag_email   = "${var.tag_email}"
  tag_manager = "${var.tag_manager}"
  tag_market  = "${var.tag_market}"
  tag_office  = "${var.tag_office}"
}


# Build S3-bucket
module "s3-bucket" {
  source      = "../modules/s3-bucket/"
  bucket_name = "${var.stack_name}-lambdas"

  tag_email   = "${var.tag_email}"
  tag_manager = "${var.tag_manager}"
  tag_market  = "${var.tag_market}"
  tag_office  = "${var.tag_office}"
}

# Generate Jenkins Parameters
module "jenkins" {
  source  = "../modules/jenkins/"
  subnets = "${module.vpc.subnets}"

  tag_email   = "${var.tag_email}"
  tag_manager = "${var.tag_manager}"
  tag_market  = "${var.tag_market}"
  tag_office  = "${var.tag_office}"
}

resource "null_resource" "jenkins-deploy" {
  provisioner "local-exec" {
    command = "jx install ${module.jenkins.jx_params}"
  }
}
