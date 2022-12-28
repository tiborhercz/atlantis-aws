provider "aws" {
  region = local.region
}

locals {
  region = "eu-west-1"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "v3.18.1"

  name = var.name

  cidr            = var.cidr
  azs             = var.azs
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  enable_nat_gateway = true
}

resource "aws_kms_key" "atlantis" {
  count = var.logs_kms_key_id == "" ? 1 : 0

  description = "${var.name}-ecs-cluster"
}

resource "aws_ecs_cluster" "atlantis" {
  name = var.name

  configuration {
    execute_command_configuration {
      kms_key_id = var.logs_kms_key_id == "" ? aws_kms_key.atlantis[0].id : var.logs_kms_key_id
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
  name = "${var.name}-ecs-logs"

  kms_key_id = var.logs_kms_key_id
}

resource "aws_cloudwatch_log_group" "atlantis_container" {
  name = "${var.name}-container-logs"

  kms_key_id = var.logs_kms_key_id == "" ? aws_kms_key.atlantis[0].id : var.logs_kms_key_id
}

module "atlantis" {
  source = "../../"

  name            = var.name
  ecs_task_cpu    = var.ecs_task_cpu
  ecs_task_memory = var.ecs_task_memory
  logs_kms_key_id = var.logs_kms_key_id

  vpc_id          = module.vpc.vpc_id
  private_subnets = module.vpc.private_subnets

  create_ecs_cluster = false
  ecs_cluster_name   = aws_ecs_cluster.atlantis.name
  ecs_cluster_id     = aws_ecs_cluster.atlantis.id

  container_cloudwatch_log_group_name = aws_cloudwatch_log_group.atlantis_container.name

  container_definitions = jsonencode([
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
          "awslogs-group"         = aws_cloudwatch_log_group.atlantis_container.name
          "awslogs-region"        = local.region
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])

  depends_on = [aws_cloudwatch_log_group.atlantis_container]
}
