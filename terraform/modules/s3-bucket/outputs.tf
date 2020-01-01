#Outputs
output "bucket_id" {
  value = aws_s3_bucket.bucket.id
}

output "bucket_name" {
  value = aws_s3_bucket.bucket
}

