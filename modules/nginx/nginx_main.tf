resource "aws_instance" "nginx_server" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = var.subnet_id
  #key_name      = var.key_name #ssh key-pair name

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              amazon-linux-extras install nginx1.12 -y
              systemctl start nginx
              systemctl enable nginx
              echo "<h1>Welcome to Nginx on AWS</h1>" > /usr/share/nginx/html/index.html
              EOF

  vpc_security_group_ids = [aws_security_group.nginx_sg.id]

  tags = merge({
    Name = "${var.env}-ec2-${var.instance_name}"
  }, var.tags)
}

resource "aws_security_group" "nginx_sg" {
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


