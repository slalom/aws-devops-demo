# Output KMS key id, S3 bucket name and secret name in the form of jx install options
output "jx_params" {
  value = module.jenkins.jx_params
}
