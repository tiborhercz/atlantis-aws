resource "aws_ecs_cluster" "atlantis" {
  count = var.create_ecs_cluster ? 1 : 0

  name = var.name
  configuration {
    execute_command_configuration {
      kms_key_id = var.cloudwatch_logs_kms_key_id
      logging    = "OVERRIDE"

      log_configuration {
        cloud_watch_encryption_enabled = true
        cloud_watch_log_group_name     = aws_cloudwatch_log_group.atlantis[0].name
      }
    }
  }

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_cloudwatch_log_group" "atlantis" {
  count = var.create_ecs_cluster ? 1 : 0

  name       = "${var.name}-ecs-logs"
  kms_key_id = var.cloudwatch_logs_kms_key_id
}
