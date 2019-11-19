# This snippet of Terraform code sets EKS and up needed resources on AWS. It outputs the parameters you then need to add to append to jx install
# Source: https://jenkins-x.io/docs/getting-started/setup/create-cluster/amazon/terraform/

variable "region" {
}

variable "subnets" {
  type = "list"
}

variable "vpc_id" {
}

variable "key_name" {
  description = "SSH key name for worker nodes"
}

variable "bucket_domain" {
  description = "Suffix for S3 bucket used for vault unseal operation"
}

provider "aws" {
  region = "${var.region}"
}

module "eks" {
  source       = "terraform-aws-modules/eks/aws"
  cluster_name = "${var.region}"
  subnets      = "${var.subnets}"
  vpc_id       = "${var.vpc_id}"
  worker_groups = [
    {
      autoscaling_enabled  = true
      asg_min_size         = 3
      asg_desired_capacity = 3
      instance_type        = "t3.large"
      asg_max_size         = 20
      key_name             = "${var.key_name}"
    }
  ]
  version = "5.0.0"
  tags = {
    Name                = "${var.bucket_name}"
    Manager             = "${var.tag_manager}"
    Market              = "${var.tag_market}"
    Engagement Office = "${var.tag_office}"
    Email               = "${var.tag_email}"
  }
}

# Needed for cluster-autoscaler
resource "aws_iam_role_policy_attachment" "workers_AmazonEC2ContainerRegistryPowerUser" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
  role       = "${module.eks.worker_iam_role_name}"
  tags = {
    Name                = "${var.bucket_name}"
    Manager             = "${var.tag_manager}"
    Market              = "${var.tag_market}"
    Engagement Office = "${var.tag_office}"
    Email               = "${var.tag_email}"
  }
}

# Create S3 bucket for KMS
resource "aws_s3_bucket" "vault-unseal" {
  bucket = "vault-unseal.${var.region}.${var.bucket_domain}"
  acl    = "private"

  versioning {
    enabled = false
  }
  tags = {
    Name                = "${var.bucket_name}"
    Manager             = "${var.tag_manager}"
    Market              = "${var.tag_market}"
    Engagement Office = "${var.tag_office}"
    Email               = "${var.tag_email}"
  }
}

# Create KMS key
resource "aws_kms_key" "bank_vault" {
  description = "KMS Key for bank vault unseal"
  tags = {
    Name                = "${var.bucket_name}"
    Manager             = "${var.tag_manager}"
    Market              = "${var.tag_market}"
    Engagement Office = "${var.tag_office}"
    Email               = "${var.tag_email}"
  }
}

# Create DynamoDB table
resource "aws_dynamodb_table" "vault-data" {
  name           = "vault-data"
  read_capacity  = 2
  write_capacity = 2
  hash_key       = "Path"
  range_key      = "Key"
  attribute {
    name = "Path"
    type = "S"
  }

  attribute {
    name = "Key"
    type = "S"
  }
  tags = {
    Name                = "${var.bucket_name}"
    Manager             = "${var.tag_manager}"
    Market              = "${var.tag_market}"
    Engagement Office = "${var.tag_office}"
    Email               = "${var.tag_email}"
  }
}

# Create service account for vault. Should the policy
resource "aws_iam_user" "vault" {
  name = "vault_${var.region}"
  tags = {
    Name                = "${var.bucket_name}"
    Manager             = "${var.tag_manager}"
    Market              = "${var.tag_market}"
    Engagement Office = "${var.tag_office}"
    Email               = "${var.tag_email}"
  }
}

data "aws_iam_policy_document" "vault" {
  statement {
    sid    = "DynamoDB"
    effect = "Allow"
    actions = [
      "dynamodb:DescribeLimits",
      "dynamodb:DescribeTimeToLive",
      "dynamodb:ListTagsOfResource",
      "dynamodb:DescribeReservedCapacityOfferings",
      "dynamodb:DescribeReservedCapacity",
      "dynamodb:ListTables",
      "dynamodb:BatchGetItem",
      "dynamodb:BatchWriteItem",
      "dynamodb:CreateTable",
      "dynamodb:DeleteItem",
      "dynamodb:GetItem",
      "dynamodb:GetRecords",
      "dynamodb:PutItem",
      "dynamodb:Query",
      "dynamodb:UpdateItem",
      "dynamodb:Scan",
      "dynamodb:DescribeTable"
    ]
    resources = ["${aws_dynamodb_table.vault-data.arn}"]
  }
  statement {
    sid    = "S3"
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:GetObject"
    ]
    resources = ["${aws_s3_bucket.vault-unseal.arn}/*"]
  }
  statement {
    sid    = "S3List"
    effect = "Allow"
    actions = [
      "s3:ListBucket"
    ]
    resources = ["${aws_s3_bucket.vault-unseal.arn}"]
  }
  statement {
    sid    = "KMS"
    effect = "Allow"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:DescribeKey"
    ]
    resources = ["${aws_kms_key.bank_vault.arn}"]
  }
  tags = {
    Name                = "${var.bucket_name}"
    Manager             = "${var.tag_manager}"
    Market              = "${var.tag_market}"
    Engagement Office = "${var.tag_office}"
    Email               = "${var.tag_email}"
  }
}

resource "aws_iam_user_policy" "vault" {
  name = "vault_${var.region}"
  user = "${aws_iam_user.vault.name}"

  policy = "${data.aws_iam_policy_document.vault.json}"
  tags = {
    Name                = "${var.bucket_name}"
    Manager             = "${var.tag_manager}"
    Market              = "${var.tag_market}"
    Engagement Office = "${var.tag_office}"
    Email               = "${var.tag_email}"
  }
}

resource "aws_iam_access_key" "vault" {
  user = "${aws_iam_user.vault.name}"
  tags = {
    Name                = "${var.bucket_name}"
    Manager             = "${var.tag_manager}"
    Market              = "${var.tag_market}"
    Engagement Office = "${var.tag_office}"
    Email               = "${var.tag_email}"
  }
}

# Output KMS key id, S3 bucket name and secret name in the form of jx install options
output "jx_params" {
  value = "--provider=eks --gitops --no-tiller --vault --aws-dynamodb-region=${var.region} --aws-dynamodb-table=${aws_dynamodb_table.vault-data.name} --aws-kms-region=${var.region} --aws-kms-key-id=${aws_kms_key.bank_vault.key_id} --aws-s3-region=${var.region}  --aws-s3-bucket=${aws_s3_bucket.vault-unseal.id} --aws-access-key-id=${aws_iam_access_key.vault.id} --aws-secret-access-key=${aws_iam_access_key.vault.secret}"
}
