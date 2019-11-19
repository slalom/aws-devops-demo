#Create an IAM Role for the Lambda  
resource "aws_iam_role" "lambda_iam" {
  name               = "${var.function_name.iam}"
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
    Name                = "${var.stack_name}-lambda"
    Manager             = "${var.tag_manager}"
    Market              = "${var.tag_market}"
    Engagement Office = "${var.tag_office}"
    Email               = "${var.tag_email}"
  }
}

resource "aws_iam_policy" "lambda_iam_policy" {
  name        = "${var.function_name}-iam-policy"
  path        = "/"
  description = "IAM policy for a lambda function"

  policy = "${data.local_file.lambda_policy.content}"
  tags = {
    Name                = "${var.stack_name}-lambda"
    Manager             = "${var.tag_manager}"
    Market              = "${var.tag_market}"
    Engagement Office = "${var.tag_office}"
    Email               = "${var.tag_email}"
  }
}


resource "aws_iam_role_policy_attachment" "lambda-policy" {
  role       = "${aws_iam_role.lambda_iam.name}"
  policy_arn = "${aws_iam_policy.lambda_iam_policy.arn}"
  tags = {
    Name                = "${var.stack_name}-lambda"
    Manager             = "${var.tag_manager}"
    Market              = "${var.tag_market}"
    Engagement Office = "${var.tag_office}"
    Email               = "${var.tag_email}"
  }
}

#Instructions here if you want to include dependencies, or a venv: https://docs.aws.amazon.com/lambda/latest/dg/lambda-python-how-to-create-deployment-package.html

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "../../${var.app}/app/${var.app}.py"
  output_path = "../../${var.app}/app/${var.app}/${var.app}.zip"
}

# upload zip to s3
resource "aws_s3_bucket_object" "file_upload" {
  bucket = "${var.s3-bucket}"
  key    = "../../compiled_functions/demo_lambda.zip"
  source = "${data.archive_file.lambda_zip.output_path}" # its mean it depended on zip
  tags = {
    Name                = "${var.stack_name}-lambda"
    Manager             = "${var.tag_manager}"
    Market              = "${var.tag_market}"
    Engagement Office = "${var.tag_office}"
    Email               = "${var.tag_email}"
  }
}

resource "aws_lambda_function" "demo_lambda" {
  function_name    = "demo_lambda"
  handler          = "app.lambda_handler"
  runtime          = "python3.7"
  s3_bucket        = "${module.s3-bucket.bucket_id}"
  s3_key           = "compiled_functions/demo_lambda.zip"
  role             = "${aws_iam_role.lambda_exec_role.arn}"
  source_code_hash = "${filebase64sha256("../../hello-world/hello_world/demo_lambda.zip")}"

  tags = {
    Name                = "${var.stack_name}-lambda"
    Manager             = "${var.tag_manager}"
    Market              = "${var.tag_market}"
    Engagement Office = "${var.tag_office}"
    Email               = "${var.tag_email}"
  }
}


resource "aws_sqs_queue" "function_updates_queue" {
  name                       = "${var.function_name}-updates-queue"
  visibility_timeout_seconds = 90
  tags = {
    Name                = "${var.stack_name}-lambda"
    Manager             = "${var.tag_manager}"
    Market              = "${var.tag_market}"
    Engagement Office = "${var.tag_office}"
    Email               = "${var.tag_email}"
  }
}

resource "aws_sqs_queue_policy" "sqs_policy" {
  queue_url = "${aws_sqs_queue.function_updates_queue.id}"
  policy    = "${data.aws_iam_policy_document.sqs_upload.json}"
  tags = {
    Name                = "${var.stack_name}-lambda"
    Manager             = "${var.tag_manager}"
    Market              = "${var.tag_market}"
    Engagement Office = "${var.tag_office}"
    Email               = "${var.tag_email}"
  }
}

resource "aws_sns_topic_subscription" "function_updates_sqs_target" {
  topic_arn     = "${var.sns_topic_arn}"
  protocol      = "sqs"
  endpoint      = "${aws_sqs_queue.function_updates_queue.arn}"
  filter_policy = "${var.filter_policy}"
  tags = {
    Name                = "${var.stack_name}-lambda"
    Manager             = "${var.tag_manager}"
    Market              = "${var.tag_market}"
    Engagement Office = "${var.tag_office}"
    Email               = "${var.tag_email}"
  }
}

resource "aws_lambda_event_source_mapping" "event_source_mapping" {
  batch_size       = 1
  event_source_arn = "${aws_sqs_queue.function_updates_queue.arn}"
  enabled          = true
  function_name    = "${aws_lambda_function.lambda_function.arn}"
  tags = {
    Name                = "${var.stack_name}-lambda"
    Manager             = "${var.tag_manager}"
    Market              = "${var.tag_market}"
    Engagement Office = "${var.tag_office}"
    Email               = "${var.tag_email}"
  }
}
