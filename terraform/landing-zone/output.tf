#Outputs
output "bucket_id" {
  value = "${module.s3-bucket.bucket_id}"
}

output "bucket_name" {
  value = "${module.s3-bucket.bucket_name}"
}
