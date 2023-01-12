provider "aws" {
  region = local.region
}

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

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
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway = true
}

resource "aws_kms_key" "atlantis" {
  description = "atlantis-ecs-cluster"
  policy      = data.aws_iam_policy_document.kms_key_policy.json
}

resource "aws_kms_alias" "atlantis" {
  name          = "alias/atlantis-logs"
  target_key_id = aws_kms_key.atlantis.key_id
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
  name = "atlantis-ecs-logs"

  kms_key_id = aws_kms_key.atlantis.arn
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

data "aws_iam_policy_document" "ecs_tasks" {
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
        Resource = "${module.atlantis.cloudwatch_log_group_atlantis_container_arn}:*"
      },
    ]
  })
}

resource "aws_iam_role" "ecs_task" {
  name               = "atlantis-ecs_task"
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks.json
}

module "atlantis" {
  source = "../../"

  name                       = "atlantis"
  ecs_task_cpu               = "1024"
  ecs_task_memory            = "2048"
  cloudwatch_logs_kms_key_id = aws_kms_key.atlantis.arn

  create_ecs_cluster = false
  ecs_cluster_name   = aws_ecs_cluster.atlantis.name
  ecs_cluster_id     = aws_ecs_cluster.atlantis.id
  network_configuration = {
    vpc_id          = module.vpc.vpc_id
    private_subnets = module.vpc.private_subnets
    public_subnets  = module.vpc.public_subnets
  }

  ecs_task_definition_role_arn = aws_iam_role.ecs_task.arn
  container_definitions = jsonencode([
    {
      name      = "atlantis"
      image     = "ghcr.io/runatlantis/atlantis:v0.21.0"
      essential = true
      portMappings = [
        {
          containerPort = 4141
          hostPort      = 4141
          protocol      = "tcp"
        }
      ]
      environment = [
        { "name" : "ATLANTIS_GH_USER", "value" : "test" },
        { "name" : "ATLANTIS_GH_TOKEN", "value" : "test" },
        { "name" : "ATLANTIS_GH_WEBHOOK_SECRET", "value" : "test" },
        { "name" : "ATLANTIS_REPO_ALLOWLIST", "value" : "github.com/tiborhercz/*" },
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = module.atlantis.cloudwatch_log_group_atlantis_container_name
          "awslogs-region"        = local.region
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])
}
