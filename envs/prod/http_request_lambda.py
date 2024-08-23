import requests
import boto3
from datetime import datetime

def lambda_handler(event, context):
    url = "http://server.olive0-druwa.com"
    cloudwatch = boto3.client('cloudwatch')
    
    try:
        response = requests.get(url, timeout=5)  # 타임아웃 설정
        status_code = response.status_code
        message = f"Request successful, status code: {status_code}"
    except requests.exceptions.Timeout:
        # 요청 타임아웃 예외 처리
        status_code = 408  # 408 Request Timeout 코드 사용
        message = "Request timed out"
    except requests.exceptions.ConnectionError:
        # 연결 오류 예외 처리
        status_code = 503  # 503 Service Unavailable 코드 사용
        message = "Connection error occurred"
    except requests.exceptions.RequestException as e:
        # 일반적인 요청 예외 처리
        status_code = 520  # 520 Unknown Error 코드 사용
        message = f"An error occurred: {str(e)}"
    
    # CloudWatch 메트릭 기록
    try:
        cloudwatch.put_metric_data(
            Namespace='serverStatusCode',
            MetricData=[{
                'MetricName': 'HTTPStatusCode',
                'Dimensions': [{'Name': 'URL', 'Value': url}],
                'Value': status_code,
                'Unit': 'None'
            }]
        )
        cw_message = "CloudWatch metric recorded successfully"
    except Exception as e:
        cw_message = f"Failed to record CloudWatch metric: {str(e)}"
    
    # 로그 출력
    print(f"{message} | CloudWatch Status: {cw_message} | Time: {datetime.now()}")

    # 결과 반환
    return {
        'statusCode': status_code,
        'body': {
            'message': message,
            'cloudwatch_message': cw_message,
            'time': str(datetime.now())
        }
    }
