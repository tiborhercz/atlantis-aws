provider "aws" {
  region = "eu-west-1"
}

resource "aws_ecs_cluster" "atlantis" {
  name = var.name

  configuration {
    execute_command_configuration {
      kms_key_id = var.logs_kms_key_id
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

resource "aws_kms_key" "atlantis" {
  description             = "${var.name}-ecs-cluster"
  deletion_window_in_days = 7
}

resource "aws_ecs_cluster_capacity_providers" "atlantis" {
  cluster_name = aws_ecs_cluster.atlantis.name

  capacity_providers = ["FARGATE"]
}

resource "aws_cloudwatch_log_group" "atlantis" {
  name = "${var.name}-ecs-logs"

  kms_key_id = var.logs_kms_key_id
}

resource "aws_cloudwatch_log_group" "atlantis_container" {
  name = "${var.name}-container-logs"

  kms_key_id = var.logs_kms_key_id
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

  container_definitions = jsonencode([
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

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }
}

resource "aws_ecs_service" "atlantis" {
  name            = "${var.name}-service"
  cluster         = aws_ecs_cluster.atlantis.id
  task_definition = aws_ecs_task_definition.atlantis.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  load_balancer {
    target_group_arn = aws_lb_target_group.atlantis.arn
    container_name   = var.name
    container_port   = 80
  }

  network_configuration {
    subnets         = module.vpc.private_subnets
    security_groups = [aws_security_group.atlantis_security_group.id]
  }
}

resource "aws_security_group" "atlantis_security_group" {
  name   = "atlantis_security_group"
  vpc_id = module.vpc.vpc_id
}

resource "aws_security_group_rule" "atlantis_ingress" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.atlantis_security_group.id
}

resource "aws_security_group_rule" "atlantis_egress" {
  type              = "egress"
  to_port           = 0
  from_port         = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.atlantis_security_group.id
}
