// タスク作成
resource "aws_ecs_task_definition" "schedule" {
  family                = "${local.project}-schedule"
  container_definitions = file("task-definitions/schedule.json")

  task_role_arn      = aws_iam_role.sample-task-role.arn
  execution_role_arn = aws_iam_role.sample-task-execution-role.arn

  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512

  tags = {
    Name        = "${local.project}-task-schedule"
    Environment = "ecs"
  }
}
