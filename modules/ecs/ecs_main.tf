# ECS 클러스터 생성
resource "aws_ecs_cluster" "cluster" {
  name = "${var.env}-vpc-${var.region}"
}

# ECS 태스크 정의 생성
resource "aws_ecs_task_definition" "nginx" {
  family                   = "nginx-task"
  container_definitions    = jsonencode([
    {
      name  = "nginx"
      image = "nginx:latest"
      cpu   = 256
      memory = 512
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
    }
  ])
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  memory                   = "512"
  cpu                      = "256"
  execution_role_arn       = var.task_execution_role_arn
}

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
