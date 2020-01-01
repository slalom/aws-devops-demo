resource "aws_s3_bucket" "bucket" {
  bucket = var.bucket_name
  acl    = "private"
  versioning {
    enabled = true
  }
  force_destroy = true
  lifecycle {
    prevent_destroy = false
  }
  tags = {
    Name                = var.bucket_name
    Manager             = var.tag_manager
    Market              = var.tag_market
    "Engagement Office" = var.tag_office
    Email               = var.tag_email
  }
}
