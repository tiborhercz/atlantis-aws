locals {
  default_container_definitions_used = var.container_definitions == "" ? true : false

  default_container_definitions = local.default_container_definitions_used == true ? jsonencode([
    {
      name      = var.name
      image     = "ghcr.io/runatlantis/atlantis:v0.21.0"
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.atlantis_container[0].name
          "awslogs-region"        = "eu-west-1"
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ]) : ""

  ecs_task_definition_role_arn = var.ecs_task_definition_role_arn == "" ? aws_iam_role.ecs_task[0].arn : var.ecs_task_definition_role_arn
}

resource "aws_ecs_task_definition" "atlantis" {
  family = "${var.name}-task"
  # TODO: Make a separate role for the execution_role_arn
  execution_role_arn       = local.ecs_task_definition_role_arn
  task_role_arn            = local.ecs_task_definition_role_arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.ecs_task_cpu
  memory                   = var.ecs_task_memory

  container_definitions = var.container_definitions == "" ? local.default_container_definitions : var.container_definitions

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "ARM64"
  }
}

data "aws_cloudwatch_log_group" "atlantis_container" {
  count = var.container_cloudwatch_log_group_name == "" ? 0 : 1

  name = var.container_cloudwatch_log_group_name
}

resource "aws_cloudwatch_log_group" "atlantis_container" {
  count = var.container_cloudwatch_log_group_name == "" ? 1 : 0

  name = "${var.name}-container-logs"

  kms_key_id = var.cloudwatch_logs_kms_key_id == "" ? aws_kms_key.atlantis[0].arn : var.cloudwatch_logs_kms_key_id

  depends_on = [aws_kms_key.atlantis]
}

data "aws_iam_policy_document" "ecs_tasks" {
  count = var.ecs_task_definition_role_arn == "" ? 1 : 0

  statement {
    actions = [
      "sts:AssumeRole",
    ]
    effect = "Allow"

    principals {
      type = "Service"
      identifiers = [
        "ecs-tasks.amazonaws.com"
      ]
    }
  }
}

resource "aws_iam_role_policy" "ecs_task_policy" {
  count = var.ecs_task_definition_role_arn == "" ? 1 : 0

  name = "ecs_task_policy"
  role = aws_iam_role.ecs_task[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams"
        ]
        Effect   = "Allow"
        Resource = var.container_cloudwatch_log_group_name == "" ? "${aws_cloudwatch_log_group.atlantis_container[0].arn}:*" : "${data.aws_cloudwatch_log_group.atlantis_container[0].arn}:*"
      },
    ]
  })
}

resource "aws_iam_role" "ecs_task" {
  count = var.ecs_task_definition_role_arn == "" ? 1 : 0

  name               = "${var.name}-ecs_task"
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks[0].json
}
