#Variables
# Tags
variable "tag_manager" {
}

variable "tag_email" {
}

variable "tag_market" {
}

variable "tag_office" {
}

# Infra
variable "stack_name" {
}

variable "environment" {
}

data "aws_iam_policy_document" "sns_upload" {
  policy_id = "snssqssns"

  statement {
    actions = [
      "SNS:Publish",
    ]

    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"

      values = [
        "arn:aws:s3:::*",
      ]
    }

    effect = "Allow"

    principals {
      type = "AWS"

      identifiers = [
        "*",
      ]
    }

    resources = [
      "arn:aws:sns:*:*:*",
    ]

    sid = "snssqssnss3upload"
  }
}
