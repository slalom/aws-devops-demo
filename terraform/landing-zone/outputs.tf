#Outputs
# output "bucket_id" {
#   value = module.s3-bucket.bucket_id
# }

# output "bucket_name" {
#   value = module.s3-bucket.bucket_name
# }

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "vpc_public_subnets" {
  value = module.vpc.public_subnets
}

output "vpc_developer_key_name" {
  value = module.vpc.developer_key_name
}
