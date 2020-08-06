
// サービス作成
resource "aws_ecs_service" "queue" {
  name            = "queue"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.queue.arn

  launch_type   = "FARGATE"
  desired_count = 1

  network_configuration {
    subnets          = [aws_subnet.main-public-a.id, aws_subnet.main-public-c.id]
    security_groups  = [aws_security_group.web.id]
    assign_public_ip = true
  }
}

// キューの作成
resource "aws_sqs_queue" "queue" {
  name = "${local.project}-queue"
}

// オートスケーリングポリシーの作成
resource "aws_appautoscaling_target" "queue" {
  service_namespace = "ecs"
  resource_id = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.queue.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  max_capacity = 4
  min_capacity = 1
}

resource "aws_appautoscaling_policy" "queue" {
  name = "${local.project}-queue-as"
  policy_type = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.queue.resource_id
  scalable_dimension = aws_appautoscaling_target.queue.scalable_dimension
  service_namespace  = aws_appautoscaling_target.queue.service_namespace
  target_tracking_scaling_policy_configuration {
    target_value = 5
    scale_out_cooldown = 300
    scale_in_cooldown = 300
    disable_scale_in = false
    customized_metric_specification {
      metric_name = "ApproximateNumberOfMessagesVisible"
      namespace   = "AWS/SQS"
      statistic   = "Average"
      unit = "Count"
      dimensions {
        name  = "QueueName"
        value = aws_sqs_queue.queue.name
      }
    }
  }
}

