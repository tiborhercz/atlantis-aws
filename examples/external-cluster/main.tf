provider "aws" {
  region = local.region
}

locals {
  region = "eu-west-1"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "v3.18.1"

  name = "atlantis"

  cidr            = "10.0.0.0/16"
  azs             = ["eu-west-1a", "eu-west-1b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24"]

  enable_nat_gateway = true
}

resource "aws_kms_key" "atlantis" {
  description = "atlantis-ecs-cluster"
}

resource "aws_ecs_cluster" "atlantis" {
  name = "atlantis"

  configuration {
    execute_command_configuration {
      kms_key_id = aws_kms_key.atlantis.id
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
  name = "atlantis-ecs-logs"

  kms_key_id = aws_kms_key.atlantis.id
}

resource "aws_cloudwatch_log_group" "atlantis_container" {
  name = "atlantis-container-logs"

  kms_key_id = aws_kms_key.atlantis.id
}

module "atlantis" {
  source = "../../"

  name                       = "atlantis"
  ecs_task_cpu               = "1024"
  ecs_task_memory            = "2048"
  cloudwatch_logs_kms_key_id = aws_kms_key.atlantis.id

  create_ecs_cluster = false
  ecs_cluster_name   = aws_ecs_cluster.atlantis.name
  ecs_cluster_id     = aws_ecs_cluster.atlantis.id
  network_configuration = {
    vpc_id          = module.vpc.vpc_id
    private_subnets = module.vpc.private_subnets
  }

  container_cloudwatch_log_group_name = aws_cloudwatch_log_group.atlantis_container.name

  container_definitions = jsonencode([
    {
      name      = "atlantis"
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
