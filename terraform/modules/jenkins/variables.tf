#Tags
variable "tag_manager" {
}

variable "tag_market" {
}

variable "tag_office" {
}

variable "tag_email" {
}

#Module Variables

variable "stack_name" {
}

variable "region" {
}

variable "vpc_id" {
}

variable "subnets" {
  type = list(string)
}

variable "developer_key_name" {
  description = "SSH key name for worker nodes"
}

variable "bucket_domain" {
  description = "Suffix for S3 bucket used for vault unseal operation"
}

