# 네트워크 생성
module "network" {
  source = "../../modules/network"

  env                       = "prod"
  region                    = "dk"
  region_id                 = "ap-northeast-1"

  tags = {
    Environment = "prod"
  }
}

# ALB 생성
resource "aws_lb" "nginx_alb" {
  name               = "nginx-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg.id]
  subnets            = [module.network.a_public_subnet_01_id,module.network.c_public_subnet_01_id]
}

resource "aws_lb_target_group" "nginx_tg" {
  name     = "nginx-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = module.network.vpc_id
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.nginx_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nginx_tg.arn
  }
}

# 보안 그룹 생성 (ALB에 대한 보안 그룹)
resource "aws_security_group" "lb_sg" {
  vpc_id = module.network.vpc_id

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

# ECS 모듈 호출
module "ecs" {
  source = "../../modules/ecs"

  #cluster_name            = "nginx-cluster"
  env                       = "prod"
  region                    = "dk"
  subnets                 = [module.network.a_public_subnet_01_id,module.network.c_public_subnet_01_id]
  security_groups         = [aws_security_group.lb_sg.id]
  task_execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
  alb_target_group_arn    = aws_lb_target_group.nginx_tg.arn

}

# IAM 역할 생성 (ECS 태스크 실행 역할)
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecs_task_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# ECS 서비스 생성 (ALB 리스너 생성 후)
resource "aws_ecs_service" "nginx_service" {
  name            = "nginx-service"
  cluster         = module.ecs.ecs_cluster_id
  task_definition = module.ecs.ecs_nginx_create_task_arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [module.network.a_public_subnet_01_id,module.network.c_public_subnet_01_id]
    security_groups  = [aws_security_group.lb_sg.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.nginx_tg.arn
    container_name   = "nginx"
    container_port   = 80
  }

  depends_on = [aws_lb_listener.http]
}

/*
module "nginx" {
  source = "../../modules/nginx"
  
  env           = "prod"
  vpc_id        = module.network.vpc_id  # network 모듈의 output 참조
  subnet_id     = module.network.a_private_subnet_02_id
  ami_id        = "ami-0091f05e4b8ee6709" #region마다 ami id 다름
  instance_type = "t2.micro"
  instance_name = "nginx"
  
  tags = {
    Environment = "prod"
  }
}
*/

/*
module "bastion" {
  source = "../../modules/bastion"
  
  env           = "prod"
  region_id                 = "ap-northeast-1"
  vpc_id        = module.network.vpc_id  # network 모듈의 output 참조
  subnet_id     = module.network.a_private_subnet_03_id
  ami_id        = "ami-0091f05e4b8ee6709" #region마다 ami id 다름
  instance_type = "t2.micro"
  instance_name = "bastion"

  tags = {
    Environment = "prod"
  }

}
*/
