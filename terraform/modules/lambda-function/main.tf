provider "aws" {
  region  = "us-west-1"
  profile = "slalom"
}

#Ensure S3 Bucket Exists
module "s3-bucket" {
  source = "./modules/s3-bucket/"
}

#Create an IAM Role for the Lambda  
resource "aws_iam_role" "lambda_exec_role" {
  name               = "lambda_exec_role"
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

#Instructions here if you want to include dependencies, or a venv: https://docs.aws.amazon.com/lambda/latest/dg/lambda-python-how-to-create-deployment-package.html

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "../../hello-world/hello_world/app.py"
  output_path = "../../hello-world/hello_world/demo_lambda.zip"
}

# upload zip to s3
resource "aws_s3_bucket_object" "file_upload" {
  bucket = "${module.s3-bucket.bucket_id}"
  key    = "../../compiled_functions/demo_lambda.zip"
  source = "${data.archive_file.lambda_zip.output_path}" # its mean it depended on zip
}

resource "aws_lambda_function" "demo_lambda" {
  function_name    = "demo_lambda"
  handler          = "app.lambda_handler"
  runtime          = "python3.7"
  s3_bucket        = "${module.s3-bucket.bucket_id}"
  s3_key           = "compiled_functions/demo_lambda.zip"
  role             = "${aws_iam_role.lambda_exec_role.arn}"
  source_code_hash = "${filebase64sha256("../../hello-world/hello_world/demo_lambda.zip")}"
}
