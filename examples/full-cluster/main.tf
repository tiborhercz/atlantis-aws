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

module "atlantis" {
  source = "../../"

  name            = var.name
  ecs_task_cpu    = ""
  ecs_task_memory = ""
  logs_kms_key_id = ""
}
