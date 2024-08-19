
module "network" {
  source = "../../modules/network"

  env                       = "prod"
  region                    = "dk"
  region_id                 = "ap-northeast-1"
  vpc_cidr_block            = "192.168.1.0/24"
  a_public_subnet_01_cidr_block  = "192.168.1.0/27"
  c_public_subnet_01_cidr_block  = "192.168.1.32/27"
  a_private_subnet_01_cidr_block = "192.168.1.64/27"
  c_private_subnet_01_cidr_block = "192.168.1.96/27"
  a_private_subnet_02_cidr_block = "192.168.1.128/27"
  c_private_subnet_02_cidr_block = "192.168.1.160/27"
  a_private_subnet_03_cidr_block = "192.168.1.192/27"

  tags = {
    Environment = "prod"
  }
}

module "nginx" {
  source = "../../modules/nginx"
  
  env           = "prod"
  vpc_id        = module.network.vpc_id  # network 모듈의 output 참조
  subnet_id     = module.network.a_private_subnet_03_id
  ami_id        = "ami-0091f05e4b8ee6709" #region마다 ami id 다름
  instance_type = "t2.micro"
  instance_name = "nginx"
  
  tags = {
    Environment = "prod"
  }
}

module "bastion" {
  source = "../../modules/bastion"
  
  env           = "prod"
  vpc_id        = module.network.vpc_id  # network 모듈의 output 참조
  subnet_id     = module.network.a_public_subnet_01_id
  ami_id        = "ami-0091f05e4b8ee6709" #region마다 ami id 다름
  instance_type = "t2.micro"
  instance_name = "bastion"
  key_name      = "bastion-key" #"module.bastion.key_pair_name"
  
  tags = {
    Environment = "prod"
  }

  # 사용자 데이터 스크립트에서 환경변수로 저장된 ssh 키 참조
  user_data = <<-EOF
    #!/bin/bash
    echo "${BASTION_PRIVATE_KEY}" > /home/ec2-user/.ssh/id_rsa
    chmod 400 /home/ec2-user/.ssh/id_rsa
  EOF
}
