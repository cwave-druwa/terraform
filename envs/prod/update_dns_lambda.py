import boto3

def lambda_handler(event, context):
    client = boto3.client('route53')
    hosted_zone_id = "Z00822742G72MYVYUGCNM"  # Hosted Zone ID
    record_name = "db.olive0-druwa.com"
    new_value = "seconddb.com"

    try:
        response = client.change_resource_record_sets(
            HostedZoneId=hosted_zone_id,
            ChangeBatch={
                'Comment': 'Switching DB record',
                'Changes': [
                    {
                        'Action': 'UPSERT',
                        'ResourceRecordSet': {
                            'Name': record_name,
                            'Type': 'CNAME',
                            'TTL': 60,
                            'ResourceRecords': [{'Value': new_value}]
                        }
                    }
                ]
            }
        )
        message = "DNS record updated successfully"
    except Exception as e:
        message = f"Failed to update DNS record: {str(e)}"
    
    # 로그 출력
    print(f"{message} | Time: {str(context.aws_request_id)}")

    # 결과 반환
    return {
        'statusCode': 200 if 'ResponseMetadata' in response and response['ResponseMetadata']['HTTPStatusCode'] == 200 else 500,
        'body': {
            'message': message,
            'request_id': context.aws_request_id,
            'time': str(context.aws_request_id)
        }
    }
