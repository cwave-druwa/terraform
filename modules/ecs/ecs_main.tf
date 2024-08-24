# ECS 클러스터 생성
resource "aws_ecs_cluster" "cluster" {
  name = "${var.env}-ecs-cluster-${var.region}"
}

/*
# ECS 태스크 정의 생성 - nginx
resource "aws_ecs_task_definition" "nginx" {
  family                   = "nginx-task"
  container_definitions    = jsonencode([
    {
      name  = "nginx"
      image = "381492005553.dkr.ecr.ap-northeast-1.amazonaws.com/my-nginx-repo:latest"
      cpu   = 256
      memory = 512
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 8080
        }
      ]
      #로그 설정 추가
      logConfiguration = {
        logDriver = "awslogs"
          options = {
            awslogs-group         = aws_cloudwatch_log_group.ecs_nginx_log_group.name
            awslogs-region        = "ap-northeast-1"
            awslogs-stream-prefix = "nginx"
          }
      }  
    }
  ])
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  memory                   = "512"
  cpu                      = "256"
  execution_role_arn       = var.task_execution_role_arn
}

# cloud watch 설정
resource "aws_cloudwatch_log_group" "ecs_nginx_log_group" {
  name              = "/ecs/ecs_nginx_create_task"
  retention_in_days = 7  # 로그 보관 기간 (예: 7일)
}
*/

# ECS 태스크 정의 생성 - olive
resource "aws_ecs_task_definition" "olive" {
  family                   = "olive-task"
  container_definitions    = jsonencode([
    {
      name  = "olive"
      image = "381492005553.dkr.ecr.ap-northeast-1.amazonaws.com/olive-young-server-dr:latest-dr"
      cpu   = 512
      memory = 1024
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 8080
        }
      ]
      #로그 설정 추가
      logConfiguration = {
        logDriver = "awslogs"
          options = {
            awslogs-group         = aws_cloudwatch_log_group.ecs_olive_log_group.name
            awslogs-region        = "ap-northeast-1"
            awslogs-stream-prefix = "olive"
          }
      }  
    }
  ])
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  memory                   = "1024"
  cpu                      = "512"
  execution_role_arn       = var.task_execution_role_arn
}

# cloud watch 설정
resource "aws_cloudwatch_log_group" "ecs_olive_log_group" {
  name              = "/ecs/ecs_olive_create_task"
  retention_in_days = 14  # 로그 보관 기간 (예: 7일)
}

/*
#main.tf로 옮겨봄
# ECS 서비스 생성
resource "aws_ecs_service" "nginx_service" {
  name            = "nginx-service"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.nginx.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.subnets
    security_groups  = var.security_groups
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.alb_target_group_arn
    container_name   = "nginx"
    container_port   = 80
  }

 #depends_on = [aws_lb_listener.http]
}
*/