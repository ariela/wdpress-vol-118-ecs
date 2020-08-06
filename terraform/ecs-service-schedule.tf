
// サービス作成
resource "aws_ecs_service" "schedule" {
  name            = "schedule"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.schedule.arn

  launch_type   = "FARGATE"
  desired_count = 1

  network_configuration {
    subnets          = [aws_subnet.main-public-a.id, aws_subnet.main-public-c.id]
    security_groups  = [aws_security_group.web.id]
    assign_public_ip = true
  }
}