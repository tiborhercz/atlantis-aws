provider "aws" {
  region = "eu-west-1"
}

locals {
  default_container_definitions = jsonencode([
    {
      name         = var.name
      image        = "ghcr.io/runatlantis/atlantis:v0.21.0"
      essential    = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options   = {
          "awslogs-group"         = aws_cloudwatch_log_group.atlantis_container.name
          "awslogs-region"        = "eu-west-1"
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])
}

resource "aws_kms_key" "atlantis" {
  count = var.logs_kms_key_id == "" ? 1 : 0

  description             = "${var.name}-ecs-cluster"
  deletion_window_in_days = 7
}

resource "aws_ecs_cluster_capacity_providers" "atlantis" {
  cluster_name = var.create_ecs_cluster ? aws_ecs_cluster.atlantis.name : var.ecs_cluster_name

  capacity_providers = ["FARGATE"]
}

resource "aws_cloudwatch_log_group" "atlantis_container" {
  name = "${var.name}-container-logs"

  kms_key_id = var.logs_kms_key_id == "" ? aws_kms_key.atlantis.id : var.logs_kms_key_id == ""
}

data "aws_iam_policy_document" "ecs_tasks" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = [
        "ecs-tasks.amazonaws.com"
      ]
    }
  }
}

resource "aws_iam_role_policy" "ecs_task_policy" {
  name = "ecs_task_policy"
  role = aws_iam_role.ecs_task.id

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
        Resource = "${aws_cloudwatch_log_group.atlantis_container.arn}:*"
      },
    ]
  })
}

resource "aws_iam_role" "ecs_task" {
  name               = "${var.name}-ecs_task"
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks.json
}

resource "aws_ecs_task_definition" "atlantis" {
  family                   = "${var.name}-task"
  execution_role_arn       = aws_iam_role.ecs_task.arn
  task_role_arn            = aws_iam_role.ecs_task.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.ecs_task_cpu
  memory                   = var.ecs_task_memory

  container_definitions = var.container_definitions == "" ? local.default_container_definitions : var.container_definitions

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }
}

resource "aws_ecs_service" "atlantis" {
  name            = "${var.name}-service"
  cluster         = var.create_ecs_cluster ? aws_ecs_cluster.atlantis.id : ecs_cluster_id
  task_definition = aws_ecs_task_definition.atlantis.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  load_balancer {
    target_group_arn = aws_lb_target_group.atlantis.arn
    container_name   = var.name
    container_port   = 80
  }

  network_configuration {
    subnets         = var.private_subnets
    security_groups = [aws_security_group.atlantis_security_group.id]
  }
}
