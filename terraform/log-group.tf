resource "aws_cloudwatch_log_group" "main" {
  name              = "${local.project}-logs"
  retention_in_days = 7
}