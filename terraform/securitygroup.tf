// ロードバランサ用セキュリティグループ
resource "aws_security_group" "loadbalancer" {
  name   = "${local.project}-loadbalancer"
  description = "LoadBalancer Access Control"
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "${local.project}-loadbalancer"
    Environment = "ecs"
  }
}

resource "aws_security_group_rule" "loadbalancer-all-to-internet" {
  security_group_id = aws_security_group.loadbalancer.id
  protocol          = "tcp"
  from_port         = 0
  to_port           = 65535
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
}
resource "aws_security_group_rule" "loadbalancer-http-from-internet" {
  security_group_id = aws_security_group.loadbalancer.id
  protocol          = "tcp"
  from_port         = 80
  to_port           = 80
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "loadbalancer-https-from-internet" {
  security_group_id = aws_security_group.loadbalancer.id
  protocol          = "tcp"
  from_port         = 443
  to_port           = 443
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}

// Webタスク用セキュリティグループ
resource "aws_security_group" "web" {
  name   = "${local.project}-web"
  description = "Web ECS Task Access Control"
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "${local.project}-web"
    Environment = "ecs"
  }
}

resource "aws_security_group_rule" "web-all-to-internet" {
  security_group_id = aws_security_group.web.id
  protocol          = "tcp"
  from_port         = 0
  to_port           = 65535
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "web-http-from-loadbalancer" {
  security_group_id        = aws_security_group.web.id
  protocol                 = "tcp"
  from_port                = 80
  to_port                  = 80
  type                     = "ingress"
  source_security_group_id = aws_security_group.loadbalancer.id
}
