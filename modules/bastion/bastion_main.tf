resource "aws_instance" "bastion_server" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = var.subnet_id
  key_name      = var.key_name #ssh key-pair name

  vpc_security_group_ids = [aws_security_group.bastion_sg.id]

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


#key-pair 생성
resource "tls_private_key" "bastion" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_key_pair" "bastion" {
  key_name   = var.key_name
  public_key = tls_private_key.bastion.public_key_openssh

  tags = merge({
    Name = "${var.env}-key-${var.instance_name}"
  }, var.tags)
}

