resource "aws_instance" "bastion_server" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = var.subnet_id
  key_name      = var.key_name #ssh key-pair name

  vpc_security_group_ids = [aws_security_group.bastion_sg.id]

  # 사용자 데이터 스크립트에서 환경변수로 저장된 ssh 키 참조
  user_data = <<-EOF
    #!/bin/bash
    echo "${BASTION_PRIVATE_KEY}" > /home/ec2-user/.ssh/id_rsa
    chmod 400 /home/ec2-user/.ssh/id_rsa
  EOF

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

resource "aws_key_pair" "bastion" {
  key_name   = var.key_name

  tags = merge({
    Name = "${var.env}-key-${var.instance_name}"
  }, var.tags)
}

# AWS Key Pair 리소스를 생성할 시 공개 키 참조
resource "aws_key_pair" "bastion_key_pair" {
  key_name   = "bastion-key"
  public_key = file("${path.module}/bastion-key.pub")
}