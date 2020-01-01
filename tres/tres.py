import json
import boto3
import os

AWS_REGION = os.environ['AWS_REGION']

def sendMessage(account_id, snsTopic, message):
    # Create an SNS client
    sns = boto3.client('sns')
    # Publish a simple message to the specified SNS topic
    response = sns.publish(
        TopicArn='arn:aws:sns:'+AWS_REGION+':'+account_id+':'+snsTopic,
        Message=message,
        MessageAttributes={ 
            'Event': {
                'DataType': 'String',
                'StringValue': 'Done!'
            }
        }
    )
    print(response) # TODO log:INFO

def handler(event, context):
    account_id = context.invoked_function_arn.split(":")[4]
    # print("Received event: "+ json.dumps(event, indent=2)) # TODO log:DEBUG
    
    print("Tres!") # TODO log:INFO

    # Send Message
    snsTopic = "serverless-updates" # sns topic name
    message = "Sending message from "+ os.environ['AWS_LAMBDA_FUNCTION_NAME']
    sendMessage(account_id, snsTopic, message)
    return