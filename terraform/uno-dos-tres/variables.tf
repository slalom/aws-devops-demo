variable "environment" {
  default     = "dev"
  description = "Environment"
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
