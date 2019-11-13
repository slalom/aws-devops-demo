Initialize Terraform:
$ cd terraform/
$ terraform init

Create S3 Bucket
$ terraform apply

Follow instructions here to install SAM CLI: https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/serverless-getting-started.html


sam package --output-template-file packaged.yaml --s3-bucket slalom-devops-demo --profile slalom

