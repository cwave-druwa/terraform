resource "aws_instance" "bastion_server" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = var.subnet_id
  #key_name      = var.key_name #ssh key-pair name

  vpc_security_group_ids = [aws_security_group.bastion_sg.id]

  #user_data = 

  tags = merge({
    Name = "${var.env}-ec2-${var.instance_name}"
  }, var.tags)
}

resource "aws_security_group" "bastion_sg" {
  name        = "${var.env}-ec2-${var.instance_name}-sg"
  description = "Allow SSH and HTTP traffic"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]  # HTTPS 접근 허용
  }

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

  tags = merge({
    Name = "${var.env}-ec2-${var.instance_name}-sg"
  }, var.tags)
}

# SSM 관련 VPC Endpoint 생성
resource "aws_vpc_endpoint" "ssm" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${var.region}.ssm"
  vpc_endpoint_type = "Interface"
  subnet_ids        = var.subnet_id
  security_group_ids = [aws_security_group.bastion_sg.id]
}

resource "aws_vpc_endpoint" "ec2messages" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${var.region}.ec2messages"
  vpc_endpoint_type = "Interface"
  subnet_ids        = var.subnet_id
  security_group_ids = [aws_security_group.bastion_sg.id]
}

resource "aws_vpc_endpoint" "ssmmessages" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${var.region}.ssmmessages"
  vpc_endpoint_type = "Interface"
  subnet_ids        = var.subnet_id
  security_group_ids = [aws_security_group.bastion_sg.id]
}