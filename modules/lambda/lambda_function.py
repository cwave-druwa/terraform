import boto3
import os

s3 = boto3.client('s3')
ecr_client = boto3.client('ecr')
ecs_client = boto3.client('ecs')

BUCKET_NAME = "ecs-image-digest-bucket"
OBJECT_KEY = "previous_image_digest.txt"

def lambda_handler(event, context):
    try:
        repository_name = "my-nginx-repo"
        tag = "newest"
        
        # ECR에서 최신 이미지 조회
        response = ecr_client.describe_images(repositoryName=repository_name, imageIds=[{'imageTag': tag}])
        latest_digest = response['imageDetails'][0]['imageDigest']
        
        # S3에서 이전 다이제스트 값 읽기
        try:
            previous_digest_object = s3.get_object(Bucket=BUCKET_NAME, Key=OBJECT_KEY)
            previous_digest = previous_digest_object['Body'].read().decode('utf-8').strip()
        except s3.exceptions.NoSuchKey:
            previous_digest = ""

        # 이미지가 변경되었는지 확인
        if latest_digest != previous_digest:
            # S3에 새로운 다이제스트 값 저장
            s3.put_object(Bucket=BUCKET_NAME, Key=OBJECT_KEY, Body=latest_digest)
            
            # ECS 서비스 업데이트를 트리거
            update_response = ecs_client.update_service(
                cluster='prod-ecs-cluster-dk',  # 클러스터 이름
                service='nginx-service',  # 서비스 이름
                forceNewDeployment=True    # 새로운 배포 강제
            )
            print(f"ECS 서비스 업데이트 완료: {update_response}")
        else:
            print("이미지가 최신 상태입니다.")
    
    except Exception as e:
        print(f"오류 발생: {str(e)}")
        return {
            'statusCode': 500,
            'body': f"오류 발생: {str(e)}"
        }

    return {
        'statusCode': 200,
        'body': "작업 완료"
    }
