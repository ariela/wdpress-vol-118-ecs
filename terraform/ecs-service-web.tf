
// ロードバランサ作成
resource "aws_lb" "web" {
  name            = "${local.project}-web"
  security_groups = [aws_security_group.loadbalancer.id]
  subnets         = [aws_subnet.main-public-a.id, aws_subnet.main-public-c.id]
}

resource "aws_lb_target_group" "web" {
  vpc_id               = aws_vpc.main.id
  name                 = "${local.project}-web-tg"
  protocol             = "HTTP"
  port                 = 80
  target_type          = "ip"
  deregistration_delay = 30
  slow_start           = 30
  health_check {
    path = "/robots.txt"
  }
}

resource "aws_lb_listener" "web-http" {
  load_balancer_arn = aws_lb.web.arn
  port              = 80
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web.arn
  }
}

// サービス作成
resource "aws_ecs_service" "web" {
  name            = "web"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.web.arn

  launch_type   = "FARGATE"
  desired_count = 1

  load_balancer {
    target_group_arn = aws_lb_target_group.web.arn
    container_name   = "nginx"
    container_port   = 80
  }

  network_configuration {
    subnets          = [aws_subnet.main-public-a.id, aws_subnet.main-public-c.id]
    security_groups  = [aws_security_group.web.id]
    assign_public_ip = true
  }

  depends_on = [
    aws_lb.web,
    aws_lb_listener.web-http
  ]
}