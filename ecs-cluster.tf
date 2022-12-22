resource "aws_ecs_cluster" "atlantis" {
  count = create_ecs_cluster ? 1 : 0

  name = var.name

  configuration {
    execute_command_configuration {
      kms_key_id = var.logs_kms_key_id == "" ? aws_kms_key.atlantis.id : var.logs_kms_key_id == ""
      logging    = "OVERRIDE"

      log_configuration {
        cloud_watch_encryption_enabled = true
        cloud_watch_log_group_name     = aws_cloudwatch_log_group.atlantis.name
      }
    }
  }

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_cloudwatch_log_group" "atlantis" {
  count = create_ecs_cluster ? 1 : 0

  name = "${var.name}-ecs-logs"

  kms_key_id = var.logs_kms_key_id
}
