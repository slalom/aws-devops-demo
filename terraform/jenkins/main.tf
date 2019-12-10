#Set Provider
provider "aws" {
  region  = var.region
  profile = var.profile
}

data "terraform_remote_state" "vpc" {
  backend = "local"

  config = {
    path = "/Users/gus.price/Documents/aws-devops-demo/terraform/landing-zone/terraform.tfstate"
  }
}

# Generate Jenkins Parameters
module "jenkins" {
  source             = "../modules/jenkins/"
  stack_name         = var.stack_name
  region             = var.region
  vpc_id             = data.terraform_remote_state.vpc.outputs.vpc_id
  subnets            = data.terraform_remote_state.vpc.outputs.vpc_public_subnets
  developer_key_name = data.terraform_remote_state.vpc.outputs.vpc_developer_key_name
  bucket_domain      = var.stack_name
  tag_email          = var.tag_email
  tag_manager        = var.tag_manager
  tag_market         = var.tag_market
  tag_office         = var.tag_office
}

# resource "null_resource" "jenkins-deploy" {
#   provisioner "local-exec" {
#     command = "echo -ne '\n' | jx install ${module.jenkins.jx_params}"
#   }
# }
