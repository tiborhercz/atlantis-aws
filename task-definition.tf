locals {
  default_container_definitions_used = var.container_definitions == null ? true : false

  default_container_definitions = local.default_container_definitions_used == true ? jsonencode([
    {
      name      = var.name
      image     = var.image
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
          "awslogs-group"         = aws_cloudwatch_log_group.atlantis_container.name
          "awslogs-region"        = var.region
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ]) : ""
}

resource "aws_ecs_task_definition" "atlantis" {
  family                   = var.name
  execution_role_arn       = var.ecs_task_definition_role_arn
  task_role_arn            = var.ecs_task_definition_role_arn
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

resource "aws_cloudwatch_log_group" "atlantis_container" {
  name = "${var.name}-container"

  kms_key_id        = var.cloudwatch_logs_kms_key_id
  retention_in_days = var.cloudwatch_container_logs_retention_in_days
}
