resource "aws_iam_role" "lambda_iam" {
  name = "${var.function_name}-iam"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "lambda_iam_policy" {
  name        = "${var.function_name}-iam-policy"
  path        = "/"
  description = "IAM policy for a lambda function"

  policy = "${data.local_file.lambda_policy.content}"
}


resource "aws_iam_role_policy_attachment" "lambda-policy" {
  role       = "${aws_iam_role.lambda_iam.name}"
  policy_arn = "${aws_iam_policy.lambda_iam_policy.arn}"
}

resource "aws_lambda_function" "lambda_function" {
  role             = "${aws_iam_role.lambda_iam.arn}"
  handler          = "${var.function_name}.handler"
  runtime          = "python3.6"
  filename         = "${data.archive_file.function.output_path}"
  function_name    = "${var.function_name}"
  source_code_hash = "${data.archive_file.function.output_base64sha256}"
  timeout          = 90
  tags = {
    Environment  = "${var.environment}"
  }
}

resource "aws_sqs_queue" "function_updates_queue" {
  name                       = "${var.function_name}-updates-queue"
  visibility_timeout_seconds = 90
  tags = {
    Environment  = "${var.environment}"
  }
}

resource "aws_sqs_queue_policy" "sqs_policy" {
  queue_url = "${aws_sqs_queue.function_updates_queue.id}"
  policy    = "${data.aws_iam_policy_document.sqs_upload.json}"
}

resource "aws_sns_topic_subscription" "function_updates_sqs_target" {
  topic_arn = "${var.sns_topic_arn}"
  protocol  = "sqs"
  endpoint  = "${aws_sqs_queue.function_updates_queue.arn}"
  filter_policy = "${var.filter_policy}"
}

resource "aws_lambda_event_source_mapping" "event_source_mapping" {
  batch_size       = 1
  event_source_arn = "${aws_sqs_queue.function_updates_queue.arn}"
  enabled          = true
  function_name    = "${aws_lambda_function.lambda_function.arn}"
}
