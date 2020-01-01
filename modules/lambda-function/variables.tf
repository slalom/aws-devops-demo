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

variable "s3_bucket" {
}

variable "function_name" {
  description = "Name of the function to be created."
}

variable "sns_topic_arn" {
  description = "Source stream to trigger the lambda function"
}

variable "filter_policy" {
  description = "Filter policy for the messages the function wants to receive from the SNS topic"
  default     = ""
}

#Instructions here if you want to include dependencies, or a venv: https://docs.aws.amazon.com/lambda/latest/dg/lambda-python-how-to-create-deployment-package.html

# data "archive_file" "function" {
#   type        = "zip"
#   source_dir  = "../${var.function_name}"
#   output_path = "../${var.function_name}.zip"
# }

data "aws_iam_policy_document" "sqs_upload" {
  statement {
    actions = [
      "sqs:SendMessage",
    ]

    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"

      values = [
        var.sns_topic_arn,
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
      aws_sqs_queue.function_updates_queue.arn,
    ]
  }
}

data "local_file" "lambda_policy" {
  filename = "../../${var.function_name}/policy.json"
}

