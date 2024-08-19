#####################################
# vpc 및 서브넷 생성
#####################################
# VPC 생성
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr_block
  tags = merge({
    Name = "${var.env}-vpc-${var.region}"
  }, var.tags)
}

# AZ a 퍼블릭 서브넷 생성
resource "aws_subnet" "a_public_01" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.a_public_subnet_01_cidr_block
  availability_zone       = "${var.region_id}a"
  map_public_ip_on_launch = true  #퍼블릭IP 주소 자동할당
  tags = merge({
    Name = "${var.env}-sub-a-pub01"
  }, var.tags)
}

# AZ c 퍼블릭 서브넷 생성
/*
resource "aws_subnet" "c_public_01" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.c_public_subnet_01_cidr_block
  availability_zone       = "${var.region_id}c"
  map_public_ip_on_launch = true  #퍼블릭IP 주소 자동할당
  tags = merge({
    Name = "${var.env}-sub-c-pub01"
  }, var.tags)
}
*/

# AZ a 프라이빗 서브넷1 생성
resource "aws_subnet" "a_private_01" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.a_private_subnet_01_cidr_block
  availability_zone = "${var.region_id}a"
  tags = merge({
    Name = "${var.env}-sub-a-pri01"
  }, var.tags)
}

/*
# AZ c 프라이빗 서브넷1 생성
resource "aws_subnet" "c_private_01" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.c_private_subnet_01_cidr_block
  availability_zone = "${var.region_id}c"
  tags = merge({
    Name = "${var.env}-sub-c-pri01"
  }, var.tags)
}
*/

# AZ a 프라이빗 서브넷2 생성
resource "aws_subnet" "a_private_02" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.a_private_subnet_02_cidr_block
  availability_zone = "${var.region_id}a"
  tags = merge({
    Name = "${var.env}-sub-a-pri02"
  }, var.tags)
}

/*
# AZ c 프라이빗 서브넷2 생성
resource "aws_subnet" "c_private_02" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.c_private_subnet_02_cidr_block
  availability_zone = "${var.region_id}c"
  tags = merge({
    Name = "${var.env}-sub-c-pri02"
  }, var.tags)
}
*/

# AZ a 프라이빗 서브넷3 생성
resource "aws_subnet" "a_private_03" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.a_private_subnet_03_cidr_block
  availability_zone = "${var.region_id}a"
  tags = merge({
    Name = "${var.env}-sub-a-pri03"
  }, var.tags)
}

# 인터넷 게이트웨이 생성
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = merge({
    Name = "${var.env}-igw-${var.region}"
  }, var.tags)
}

#####################################
# 퍼블릭 서브넷들에 대한 라우팅 테이블
#####################################
# 퍼블릭 라우팅 테이블 생성
resource "aws_route_table" "public_01" {
  vpc_id = aws_vpc.main.id  # VPC ID를 지정

  tags = merge({
    Name = "${var.env}-rtb-pub"
  }, var.tags)
}

resource "aws_route" "internet_access" {
  route_table_id         = aws_route_table.public_01.id  # 라우팅 테이블 ID를 지정
  destination_cidr_block = "0.0.0.0/0"  # 인터넷 경로를 지정
  gateway_id             = aws_internet_gateway.igw.id  # IGW ID를 지정
}

# 퍼블릭 서브넷들에 라우팅 테이블 연결
resource "aws_route_table_association" "a_public_01" {
  subnet_id      = aws_subnet.a_public_01.id
  route_table_id = aws_route_table.public_01.id
}

#resource "aws_route_table_association" "c_public_01" {
#  subnet_id      = aws_subnet.c_public_01.id
#  route_table_id = aws_route_table.public_01.id
#}

#####################################
# NAT
#####################################
# AZ a 퍼블릭 서브넷에 NAT 생성
resource "aws_nat_gateway" "a_nat" {
  allocation_id = aws_eip.a_nat.id
  subnet_id     = aws_subnet.a_public_01.id

  tags = merge({
    Name = "${var.env}-nat-a-pub01"
  }, var.tags)
}

# NAT에서 사용할 Elastic IP 생성
resource "aws_eip" "a_nat" {
  domain = "vpc" 
}

/*
# AZ c 퍼블릭 서브넷에 NAT 생성
resource "aws_nat_gateway" "c_nat" {
  allocation_id = aws_eip.c_nat.id
  subnet_id     = aws_subnet.c_public_01.id

  tags = merge({
    Name = "${var.env}-nat-c-pub01"
  }, var.tags)
}

# NAT에서 사용할 Elastic IP 생성
resource "aws_eip" "c_nat" {
  domain = "vpc" 
}

*/

#####################################
# AZ a 프라이빗 서브넷 1의 라우팅 테이블
#####################################
#라우팅 테이블 생성
resource "aws_route_table" "a_private_01" {
  vpc_id = aws_vpc.main.id

  tags = merge({
    Name = "${var.env}-rtb-a-pri01"
  }, var.tags)
}

# NAT 게이트웨이를 경로로 추가
resource "aws_route" "a_private_01_to_nat" {
  route_table_id         = aws_route_table.a_private_01.id  # 프라이빗 라우팅 테이블
  destination_cidr_block = "0.0.0.0/0"  # 모든 외부 트래픽에 대해
  nat_gateway_id         = aws_nat_gateway.a_nat.id   # NAT 게이트웨이 ID 참조

  depends_on = [aws_nat_gateway.a_nat]  # NAT 게이트웨이가 먼저 생성되도록 보장
}

# 서브넷과 라우팅 테이블 연결 (라우팅 테이블을 서브넷에 연결)
resource "aws_route_table_association" "a_private_01_association" {
  subnet_id      = aws_subnet.a_private_01.id  # 프라이빗 서브넷 ID
  route_table_id = aws_route_table.a_private_01.id  # 프라이빗 라우팅 테이블 ID
}

#####################################
# AZ a 프라이빗 서브넷 3의 라우팅 테이블
#####################################
#라우팅 테이블 생성
resource "aws_route_table" "a_private_03" {
  vpc_id = aws_vpc.main.id

  tags = merge({
    Name = "${var.env}-rtb-a-pri03"
  }, var.tags)
}

# NAT 게이트웨이를 경로로 추가
# bastion, gitlab ec2에 설치, 업데이트 등을 할때 필요
# 계속 필요한지에 대해 고민해볼 것
resource "aws_route" "a_private_03_to_nat" {
  route_table_id         = aws_route_table.a_private_03.id  # 프라이빗 라우팅 테이블
  destination_cidr_block = "0.0.0.0/0"  # 모든 외부 트래픽에 대해
  nat_gateway_id         = aws_nat_gateway.c_nat.id   # NAT 게이트웨이 ID 참조

  depends_on = [aws_nat_gateway.c_nat]  # NAT 게이트웨이가 먼저 생성되도록 보장
}

# 서브넷과 라우팅 테이블 연결 (라우팅 테이블을 서브넷에 연결)
resource "aws_route_table_association" "a_private_03_association" {
  subnet_id      = aws_subnet.a_private_03.id  # 프라이빗 서브넷 ID
  route_table_id = aws_route_table.a_private_03.id  # 프라이빗 라우팅 테이블 ID
}

/*
#####################################
# AZ c 프라이빗 서브넷 1의 라우팅 테이블
#####################################
#라우팅 테이블 생성
resource "aws_route_table" "c_private_01" {
  vpc_id = aws_vpc.main.id

  tags = merge({
    Name = "${var.env}-rtb-c-pri01"
  }, var.tags)
}

# NAT 게이트웨이를 경로로 추가
resource "aws_route" "c_private_01_to_nat" {
  route_table_id         = aws_route_table.c_private_01.id  # 프라이빗 라우팅 테이블
  destination_cidr_block = "0.0.0.0/0"  # 모든 외부 트래픽에 대해
  nat_gateway_id         = aws_nat_gateway.c_nat.id   # NAT 게이트웨이 ID 참조

  depends_on = [aws_nat_gateway.c_nat]  # NAT 게이트웨이가 먼저 생성되도록 보장
}

# 서브넷과 라우팅 테이블 연결 (라우팅 테이블을 서브넷에 연결)
resource "aws_route_table_association" "c_private_01_association" {
  subnet_id      = aws_subnet.c_private_01.id  # 프라이빗 서브넷 ID
  route_table_id = aws_route_table.c_private_01.id  # 프라이빗 라우팅 테이블 ID
}

*/



