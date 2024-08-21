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
            
            # 새로운 태스크 정의를 등록
            task_def_response = ecs_client.register_task_definition(
                family='nginx-task',
                containerDefinitions=[
                    {
                        'name': 'nginx',
                        'image': f'{repository_name}:{tag}',
                        'cpu': 256,
                        'memory': 512,
                        'essential': True,
                        'portMappings': [
                            {
                                'containerPort': 80,
                                'hostPort': 80
                            }
                        ]
                    }
                ],
                requiresCompatibilities=['FARGATE'],
                networkMode='awsvpc',
                memory='512',
                cpu='256',
                executionRoleArn='arn:aws:iam::381492005553:role/lambda_exec_role'
            )
            
            new_task_definition = task_def_response['taskDefinition']['taskDefinitionArn']
            
            # ECS 서비스 업데이트를 트리거하여 새로운 태스크 정의 사용
            update_response = ecs_client.update_service(
                cluster='prod-ecs-cluster-dk',
                service='nginx-service',
                taskDefinition=new_task_definition,
                forceNewDeployment=True
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
