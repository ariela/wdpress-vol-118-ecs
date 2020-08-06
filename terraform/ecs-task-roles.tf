// タスクロール作成
data "aws_iam_policy_document" "sample-task-role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "sample-task-role" {
  name               = "${local.project}-ecs-task"
  assume_role_policy = data.aws_iam_policy_document.sample-task-role.json

  tags = {
    Name        = "${local.project}-task-role"
    Environment = "ecs"
  }
}

// タスク実行ロール作成
data "aws_iam_policy_document" "sample-task-execution-role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "sample-task-execution-role" {
  name               = "${local.project}-ecs-task-execution"
  assume_role_policy = data.aws_iam_policy_document.sample-task-execution-role.json

  tags = {
    Name        = "${local.project}-task-execution-role"
    Environment = "ecs"
  }
}

resource "aws_iam_role_policy_attachment" "sample-task-execution-role-AmazonECSTaskExecutionRolePolicy" {
  role       = aws_iam_role.sample-task-execution-role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}