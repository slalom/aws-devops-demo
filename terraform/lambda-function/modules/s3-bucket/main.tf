# provider "aws" {
#   region  = "us-west-1"
#   profile = "slalom"
# }

resource "aws_s3_bucket" "bucket" {
  bucket = "slalom-devops-demo-s3"
  acl    = "private"
  versioning {
    enabled = true
  }
  tags = {
    Name = "Slalom Devops Demo S3"
  }
}
