provider "aws" {
  region = "us-west-2"
}

# This plan builds, VPC, subnet, ssh_key, s3-bucket, and required resources
#TODO: UN-HARDCODE THIS!
terraform {
  backend "s3" {
    bucket = "slalom-devops-demo-poc-terraform-states"
    key    = "slalom-devops-demo/poc/uno-dos-tres/terraform.tfstate"
    region = "us-west-2"
    # dynamodb_table = "slalom-devops-demo-poc-terraform-state-lock"
  }
}

# Build S3-bucket for lambdas
module "s3-bucket" {
  source      = "../modules/s3-bucket/"
  bucket_name = "${var.stack_name}-${var.environment}-lambda-s3"
  tag_email   = var.tag_email
  tag_manager = var.tag_manager
  tag_market  = var.tag_market
  tag_office  = var.tag_office
}

# Main SNS Topic
resource "aws_sns_topic" "serverless_updates" {
  name = "${var.stack_name}-${var.environment}-serverless-updates"
  tags = {
    Manager             = var.tag_manager
    Market              = var.tag_market
    "Engagement Office" = var.tag_office
    Email               = var.tag_email
  }
}
resource "aws_sns_topic_policy" "serverless_updates_policy" {
  arn    = aws_sns_topic.serverless_updates.arn
  policy = data.aws_iam_policy_document.sns_upload.json
}

# Lambda functions
module "uno" {
  source        = "../modules/lambda-function"
  function_name = "uno"
  sns_topic_arn = aws_sns_topic.serverless_updates.arn
  s3_bucket     = module.s3-bucket.bucket_id
  stack_name    = var.stack_name
  environment   = var.environment
  tag_email     = var.tag_email
  tag_manager   = var.tag_manager
  tag_market    = var.tag_market
  tag_office    = var.tag_office
  filter_policy = <<EOF
{
  "Event": ["Trigger Uno"]
}
EOF
}

module "dos" {
  source        = "../modules/lambda-function"
  function_name = "dos"
  sns_topic_arn = aws_sns_topic.serverless_updates.arn
  s3_bucket     = module.s3-bucket.bucket_id
  stack_name    = var.stack_name
  environment   = var.environment
  tag_email     = var.tag_email
  tag_manager   = var.tag_manager
  tag_market    = var.tag_market
  tag_office    = var.tag_office
  filter_policy = <<EOF
{
  "Event": ["Trigger Dos"]
}
EOF
}

module "tres" {
  source        = "../modules/lambda-function"
  function_name = "tres"
  sns_topic_arn = aws_sns_topic.serverless_updates.arn
  s3_bucket     = module.s3-bucket.bucket_id
  stack_name    = var.stack_name
  environment   = var.environment
  tag_email     = var.tag_email
  tag_manager   = var.tag_manager
  tag_market    = var.tag_market
  tag_office    = var.tag_office
  filter_policy = <<EOF
{
  "Event": ["Trigger Tres"]
}
EOF
}
