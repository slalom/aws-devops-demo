#Set Provider
provider "aws" {
  region = var.region
  # access_key = TF_VAR_AWS_ACCESS_KEY_ID
  # secret_key = TF_VAR_AWS_SECRET_ACCESS_KEY
}

# Build S3-bucket for terraform states
module "s3-bucket" {
  source      = "../modules/s3-bucket/"
  bucket_name = "${var.stack_name}-${var.environment}-terraform-states"
  tag_email   = var.tag_email
  tag_manager = var.tag_manager
  tag_market  = var.tag_market
  tag_office  = var.tag_office
}

resource "aws_dynamodb_table" "terraform_state_lock" {
  name           = "app-state"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
  tags = {
    Name                = "${var.stack_name}-${var.environment}-terraform-state-lock"
    Manager             = var.tag_manager
    Market              = var.tag_market
    "Engagement Office" = var.tag_office
    Email               = var.tag_email
  }
}
