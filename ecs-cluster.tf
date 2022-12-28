resource "aws_ecs_cluster" "atlantis" {
  count = var.create_ecs_cluster ? 1 : 0

  name = var.name
  configuration {
    execute_command_configuration {
      kms_key_id = var.cloudwatch_logs_kms_key_id == "" ? aws_kms_key.atlantis[0].id : var.cloudwatch_logs_kms_key_id
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

resource "aws_kms_key" "atlantis" {
  count = var.cloudwatch_logs_kms_key_id == "" ? 1 : 0

  description = "${var.name}-ecs-cluster"
  policy      = data.aws_iam_policy_document.kms_key_policy.json
}

resource "aws_kms_alias" "a" {
  name          = "alias/${var.name}"
  target_key_id = aws_kms_key.atlantis[0].key_id
}

data "aws_iam_policy_document" "kms_key_policy" {
  statement {
    sid    = "Enable IAM User Permissions"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }

    actions = [
      "kms:*"
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "kms:Encrypt*",
      "kms:Decrypt*",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:Describe*"
    ]
    principals {
      type        = "Service"
      identifiers = ["logs.${data.aws_region.current.name}.amazonaws.com"]
    }
    resources = ["*"]
    condition {
      test = "ForAnyValue:ArnEquals"
      values = [
        "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:*",
      ]
      variable = "kms:EncryptionContext:aws:logs:arn"
    }
  }
}

resource "aws_cloudwatch_log_group" "atlantis" {
  count = var.create_ecs_cluster ? 1 : 0

  name       = "${var.name}-ecs-logs"
  kms_key_id = var.cloudwatch_logs_kms_key_id
}
