// VPC定義
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name        = "${local.project}-vpc"
    Environment = "ecs"
  }
}

// サブネット定義(public/zone-a)
resource "aws_subnet" "main-public-a" {
  vpc_id                  = aws_vpc.main.id
  availability_zone       = "ap-northeast-1a"
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name        = "${local.project}-public-a"
    Environment = "ecs"
  }
}

// サブネット定義(public/zone-c)
resource "aws_subnet" "main-public-c" {
  vpc_id                  = aws_vpc.main.id
  availability_zone       = "ap-northeast-1c"
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name        = "${local.project}-public-c"
    Environment = "ecs"
  }
}

// インターネットゲートウェイ
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "${local.project}-igw"
    Environment = "ecs"
  }
}

resource "aws_default_route_table" "default" {
  default_route_table_id = aws_vpc.main.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name        = "${local.project}-default-rt"
    Environment = "ecs"
  }
}
