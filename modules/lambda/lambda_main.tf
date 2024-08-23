#######################################
# 이미지 다이제스트 비교후 ECS 업데이트 #
#######################################
# Lambda 함수 정의
resource "aws_lambda_function" "check_ecr_lambda" {
  filename         = "check_ecr_lambda.zip"
  function_name    = check_ecr_lambda
  role             = aws_iam_role.lambda_exec.arn
  handler          = "check_ecr_lambda.lambda_handler"
  runtime          = python3.8
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
  schedule_expression = "rate(2 minutes)"  #테스트 용 2분 마다
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
  policy_arn = "arn:aws:iam::aws:policy/AmazonECS_FullAccess"
}

resource "aws_iam_policy_attachment" "attach_s3_policy" {
  name       = "attach_s3_policy"
  roles      = [aws_iam_role.lambda_exec.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}


#########################################
# server.olive0-druwa.com 상태 체크 람다 #
#########################################
/*
# 보안 그룹 생성
resource "aws_security_group" "lambda_sg" {
  name        = "lambda_sg"
  description = "Security group for Lambda functions"
  vpc_id      = var.vpc_id  # 기존 VPC ID를 사용합니다.

  ingress {
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
*/

# Lambda 역할 생성
resource "aws_iam_role" "lambda_role" {
  name = "lambda_dns_update_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action    = "sts:AssumeRole",
        Effect    = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# Lambda 역할에 필요한 정책 추가 (CloudWatch 및 Route53 액세스 권한)
resource "aws_iam_policy" "lambda_policy" {
  name = "lambda_cloudwatch_route53_policy"

  policy = jsonencode({
    Version: "2012-10-17",
    Statement: [
      {
        Effect: "Allow",
        Action: [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "cloudwatch:PutMetricData"
        ],
        Resource: "*"
      },
      {
        Effect: "Allow",
        Action: [
          "route53:ChangeResourceRecordSets",
          "route53:ListHostedZonesByName",
          "route53:GetChange"
        ],
        Resource: "*"
      }
    ]
  })
}

# Lambda 역할에 정책 부여
resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

# Lambda 역할에 기본 실행 권한 추가 (CloudWatch Logs 및 CloudWatch Metrics)
resource "aws_iam_policy_attachment" "lambda_basic_execution_policy" {
  name       = "lambda_basic_execution"
  roles      = [aws_iam_role.lambda_role.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# 첫 번째 Lambda 함수의 CloudWatch 로그 그룹 생성
resource "aws_cloudwatch_log_group" "http_request_lambda_log_group" {
  name              = "/aws/lambda/http_request_lambda"
  retention_in_days = 14
}

# 첫 번째 Lambda 함수 (HTTP 요청 및 CloudWatch 메트릭 기록)
resource "aws_lambda_function" "http_request_lambda" {
  function_name = "http_request_lambda"
  role          = aws_iam_role.lambda_role.arn
  runtime       = "python3.9"
  handler       = "http_request_lambda.lambda_handler"

  # Lambda 함수 코드
  filename = "http_request_lambda.zip"  # zip 파일로 패키징된 Lambda 함수 코드
  source_code_hash = filebase64sha256("http_request_lambda.zip")

  environment {
    variables = {
      TARGET_URL = "http://server.olive0-druwa.com"
    }
  }

  depends_on = [aws_cloudwatch_log_group.http_request_lambda_log_group]
}

############################
# DB 레코드값 수정하는 람다 #
############################
# 두 번째 Lambda 함수 (Route53 레코드 업데이트)
resource "aws_lambda_function" "update_dns_lambda" {
  function_name = "update_dns_lambda"
  role          = aws_iam_role.lambda_role.arn
  runtime       = "python3.9"
  handler       = "update_dns_lambda.lambda_handler"

  # Lambda 함수 코드
  filename = "update_dns_lambda.zip"
  source_code_hash = filebase64sha256("update_dns_lambda.zip")

  environment {
    variables = {
      HOSTED_ZONE_ID = "Z00822742G72MYVYUGCNM"  # Route53 Hosted Zone ID
      RECORD_NAME   = "db.olive0-druwa.com"
      NEW_VALUE     = "seconddb.com" #기존 값 olive-young.cluster-cxseewuysq1m.ap-northeast-2.rds.amazonaws.com
    }
  }

  depends_on = [aws_cloudwatch_log_group.update_dns_lambda_log_group]
}

###########################
# cloudwatch, alarm  생성 #
###########################
# CloudWatch 메트릭 알람 설정
resource "aws_cloudwatch_metric_alarm" "http_error_alarm" {
  alarm_name                = "http_error_alarm"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "HTTPStatusCode"
  namespace                 = "serverStatusCode"
  period                    = "60"
  statistic                 = "Average"
  threshold                 = "400"  # 에러 상태 코드 기준값
  alarm_description         = "Triggers when HTTP error codes 404, 500, 501, 502, 503 occur"
  dimensions = {
    URL = "http://server.olive0-druwa.com"
  }

  #alarm_actions = [aws_cloudwatch_metric_alarm.http_error_alarm.arn]
}

# EventBridge 규칙 설정
resource "aws_cloudwatch_event_rule" "alarm_rule" {
  name        = "alarm_trigger_rule"
  description = "Rule to trigger Lambda on CloudWatch Alarm"
  event_pattern = jsonencode({
    "source": ["aws.cloudwatch"],
    "detail-type": ["CloudWatch Alarm State Change"],
    "detail": {
      "alarmName": ["http_error_alarm"]
    }
  })
}


# CloudWatch Events에서 Lambda를 트리거하는 타겟 설정
resource "aws_cloudwatch_event_target" "lambda_trigger" {
  rule = aws_cloudwatch_event_rule.alarm_rule.name
  arn  = aws_lambda_function.update_dns_lambda.arn
}

# Lambda 함수가 EventBridge에서 호출될 수 있도록 허용
resource "aws_lambda_permission" "eventbridge_lambda_permission" {
  statement_id  = "AllowEventBridgeToInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.update_dns_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.alarm_rule.arn
}

# 두 번째 Lambda 함수의 CloudWatch 로그 그룹 생성
resource "aws_cloudwatch_log_group" "update_dns_lambda_log_group" {
  name              = "/aws/lambda/update_dns_lambda"
  retention_in_days = 14
}
