provider "aws" {
  region  = "${var.region}"
  profile = "${var.profile}"
}

data "terraform_remote_state" "vpc" {
  backend = "s3"

  config = {
    bucket = "${var.stack_name}-${var.environment}-tf-states"
    key    = "${var.stack_name}-${var.environment}-vpc.terrafrom.tfstate"
    region = "${var.region}"
  }
}

module "lambda-function" {
  source    = "../modules/lambda-function"
  app       = "hello-world"
  s3-bucket = "${var.stack_name}-${var.environment}-lambdas"

  tag_email   = "${var.tag_email}"
  tag_manager = "${var.tag_manager}"
  tag_market  = "${var.tag_market}"
  tag_office  = "${var.tag_office}"
}

