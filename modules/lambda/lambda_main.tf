# Lambda 함수 정의
resource "aws_lambda_function" "check_ecr_lambda" {
  filename         = "lambda.zip"
  function_name    = var.function_name
  role             = aws_iam_role.lambda_exec.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = var.runtime
  timeout          = 30
  environment {
    variables = {
      BUCKET_NAME = aws_s3_bucket.image_digest_bucket.bucket
      OBJECT_KEY  = "previous_image_digest.txt"
    }
  }

  source_code_hash = filebase64sha256("lambda.zip")
}

# CloudWatch Events 규칙 정의 (스케줄링)
resource "aws_cloudwatch_event_rule" "trigger_lambda" {
  name                = "daily_ecr_check"
  schedule_expression = "rate(10 minutes)"  #테스트 용 10분 마다
  #schedule_expression = "cron( 0 0 * ? *)"  # 매일 자정 UTC
}

# CloudWatch Events 타겟 정의
resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.trigger_lambda.name
  target_id = "check-ecr-target"
  arn       = aws_lambda_function.check_ecr_lambda.arn
}

# Lambda 함수에 대한 CloudWatch 권한 설정
resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.check_ecr_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.trigger_lambda.arn
}

# S3 버킷 생성 (이전 다이제스트 저장용)
resource "aws_s3_bucket" "image_digest_bucket" {
  bucket = "ecs-image-digest-bucket"
  acl    = "private"
}

# IAM 역할 정의 (Lambda 실행을 위한)
resource "aws_iam_role" "lambda_exec" {
  name = "lambda_exec_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

# ECR, ECS 작업 및 S3 접근 권한 부여
resource "aws_iam_policy_attachment" "attach_ecr_policy" {
  name       = "attach_ecr_policy"
  roles      = [aws_iam_role.lambda_exec.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_policy_attachment" "attach_ecs_policy" {
  name       = "attach_ecs_policy"
  roles      = [aws_iam_role.lambda_exec.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonECSFullAccess"
}

resource "aws_iam_policy_attachment" "attach_s3_policy" {
  name       = "attach_s3_policy"
  roles      = [aws_iam_role.lambda_exec.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}
