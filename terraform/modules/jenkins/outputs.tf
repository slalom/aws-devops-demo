# Output KMS key id, S3 bucket name and secret name in the form of jx install options
output "jx_params" {
  value = "--provider=eks --ng --aws-dynamodb-region=${var.region} --aws-dynamodb-table=${aws_dynamodb_table.vault-data.name} --aws-kms-region=${var.region} --aws-kms-key-id=${aws_kms_key.bank_vault.key_id} --aws-s3-region=${var.region}  --aws-s3-bucket=${aws_s3_bucket.vault-unseal.id} --aws-access-key-id=${aws_iam_access_key.vault.id} --aws-secret-access-key=${aws_iam_access_key.vault.secret}"
}

