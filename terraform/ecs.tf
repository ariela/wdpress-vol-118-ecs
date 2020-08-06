// クラスター定義
resource "aws_ecs_cluster" "main" {
  name = "${local.project}-cluster"

  tags = {
    Name        = "${local.project}-cluster"
    Environment = "ecs"
  }
}

