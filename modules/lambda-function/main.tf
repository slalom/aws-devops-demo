#Create an IAM Role for the Lambda  
resource "aws_iam_role" "lambda_iam" {
  name               = "${var.function_name}-iam"
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


  tags = {
    Name                = "${var.stack_name}-${var.environment}-lambda"
    Manager             = var.tag_manager
    Market              = var.tag_market
    "Engagement Office" = var.tag_office
    Email               = var.tag_email
  }
}

resource "aws_iam_policy" "lambda_iam_policy" {
  name        = "${var.function_name}-iam-policy"
  path        = "/"
  description = "IAM policy for a lambda function"

  policy = data.local_file.lambda_policy.content
}

resource "aws_iam_role_policy_attachment" "lambda-policy" {
  role       = aws_iam_role.lambda_iam.name
  policy_arn = aws_iam_policy.lambda_iam_policy.arn
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "../../${var.function_name}/${var.function_name}.py"
  output_path = "../../compiled_functions/${var.function_name}-${timestamp()}.zip"
}

#upload zip to s3
resource "aws_s3_bucket_object" "file_upload" {
  bucket = var.s3_bucket
  key    = "compiled_functions/${var.function_name}.zip"
  source = data.archive_file.lambda_zip.output_path
  tags = {
    Name                = "${var.stack_name}-${var.environment}-${var.function_name}"
    Manager             = var.tag_manager
    Market              = var.tag_market
    "Engagement Office" = var.tag_office
    Email               = var.tag_email
  }
}

resource "aws_lambda_function" "demo_lambda" {
  # depends_on    = [aws_s3_bucket_object.file_upload]
  function_name = var.function_name
  handler       = "${var.function_name}.lambda_handler"
  runtime       = "python3.7"
  filename      = data.archive_file.lambda_zip.output_path
  # s3_bucket     = var.s3_bucket
  # s3_key        = "compiled_functions/${var.function_name}.zip"
  role    = aws_iam_role.lambda_iam.arn
  timeout = 90
  # source_code_hash = filebase64sha256("${var.function_name}.zip")

  tags = {
    Name                = "${var.stack_name}-${var.environment}-lambda"
    Manager             = var.tag_manager
    Market              = var.tag_market
    "Engagement Office" = var.tag_office
    Email               = var.tag_email
  }
}

resource "aws_sqs_queue" "function_updates_queue" {
  name                       = "${var.function_name}-updates-queue"
  visibility_timeout_seconds = 90
  tags = {
    Name                = "${var.stack_name}-${var.environment}-lambda"
    Manager             = var.tag_manager
    Market              = var.tag_market
    "Engagement Office" = var.tag_office
    Email               = var.tag_email
  }
}

resource "aws_sqs_queue_policy" "sqs_policy" {
  queue_url = aws_sqs_queue.function_updates_queue.id
  policy    = data.aws_iam_policy_document.sqs_upload.json
}

resource "aws_sns_topic_subscription" "function_updates_sqs_target" {
  topic_arn     = var.sns_topic_arn
  protocol      = "sqs"
  endpoint      = aws_sqs_queue.function_updates_queue.arn
  filter_policy = var.filter_policy
}

resource "aws_lambda_event_source_mapping" "event_source_mapping" {
  batch_size       = 1
  event_source_arn = aws_sqs_queue.function_updates_queue.arn
  enabled          = true
  function_name    = aws_lambda_function.demo_lambda.arn
}

