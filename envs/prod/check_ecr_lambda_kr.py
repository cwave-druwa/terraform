import boto3
import os

# 로깅 설정
logger = logging.getLogger()
logger.setLevel(logging.INFO)

s3 = boto3.client('s3')
ecr_client = boto3.client('ecr')
ecs_client = boto3.client('ecs')

BUCKET_NAME = "ecs-image-digest-bucket"
OBJECT_KEY = "previous_image_digest.txt"

def lambda_handler(event, context):
    try:
        logger.info("Lambda 함수 실행 시작...")

        repository_name = "olive-young-server"
        tag = "latest-dr"
        
        # ECR에서 최신 이미지 조회
        try:
            response = ecr_client.describe_images(repositoryName=repository_name, imageIds=[{'imageTag': tag}])
            if len(response['imageDetails']) > 0:
                latest_digest = response['imageDetails'][0]['imageDigest']
            else:
                return {
                    'statusCode': 404,
                    'body': "No images found with the specified tag."
                }
        except Exception as e:
            return {
                'statusCode': 500,
                'body': f"Error retrieving image details from ECR: {str(e)}"
            }
        
        logger.info(f"Latest digest from ECR: {latest_digest}")
        
        # S3에서 이전 다이제스트 값 읽기
        try:
            previous_digest_object = s3.get_object(Bucket=BUCKET_NAME, Key=OBJECT_KEY)
            previous_digest = previous_digest_object['Body'].read().decode('utf-8').strip()
            logger.info(f"Previous digest from S3: {previous_digest}")
        except s3.exceptions.NoSuchKey:
            previous_digest = ""
            logger.info("No previous digest found in S3, setting to empty string.")
        
        # 이미지가 변경되었는지 확인
        if latest_digest != previous_digest:
            # 새로운 태스크 정의 등록
            task_definition_response = ecs_client.describe_task_definition(
                taskDefinition='olive-service'  # 기존 태스크 정의 이름을 사용합니다.
            )
            
            container_definitions = task_definition_response['taskDefinition']['containerDefinitions']
            # 최신 이미지 다이제스트를 적용합니다.
            for container in container_definitions:
                if container['name'] == 'olive-service-container':  # 사용 중인 컨테이너 이름에 맞게 변경
                    container['image'] = f"{repository_name}@{latest_digest}"

            new_task_definition = ecs_client.register_task_definition(
                family=task_definition_response['taskDefinition']['family'],
                containerDefinitions=container_definitions,
                requiresCompatibilities=task_definition_response['taskDefinition']['requiresCompatibilities'],
                networkMode=task_definition_response['taskDefinition']['networkMode'],
                cpu=task_definition_response['taskDefinition']['cpu'],
                memory=task_definition_response['taskDefinition']['memory'],
                executionRoleArn=task_definition_response['taskDefinition']['executionRoleArn'],
                taskRoleArn=task_definition_response['taskDefinition']['taskRoleArn']
            )

            # 새로운 태스크 정의의 ARN을 ECS 서비스 업데이트에 사용
            update_response = ecs_client.update_service(
                cluster='prod-ecs-cluster-dk',
                service='olive-service',
                taskDefinition=new_task_definition['taskDefinition']['taskDefinitionArn']
            )
            
            logger.info(f"ECS 서비스 업데이트 완료: {update_response}")

            # S3에 새로운 다이제스트 값 저장
            s3.put_object(Bucket=BUCKET_NAME, Key=OBJECT_KEY, Body=latest_digest)
            
            update_message = "ECS 서비스가 성공적으로 업데이트되었습니다."
        else:
            logger.info("이미지가 최신 상태입니다.")
            update_message = "이미지가 최신 상태입니다."
    
    except Exception as e:
        logger.error(f"오류 발생: {str(e)}")
        return {
            'statusCode': 500,
            'body': f"오류 발생: {str(e)}"
        }

    # 결과 반환
    return {
        'statusCode': 200,
        'body': {
            'previous_digest_message': previous_digest,
            'latest_digest_message': latest_digest,
            'update_message': update_message
        }
    }