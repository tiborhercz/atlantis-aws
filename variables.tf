variable "name" {
  description = "Used to name the resources"
  type        = string
}

variable "region" {
  description = "Region that the resources should be deployed in"
}

variable "cloudwatch_logs_kms_key_id" {
  description = "KMS key ID for CloudWatch Logs encryption. If not set a KMS key will be created and used."
  type        = string
  default     = null
}

variable "cloudwatch_container_logs_retention_in_days" {
  description = "The Cloudwatch container logs retention in days"
  type        = number
  default     = 90
}

variable "ecs_task_cpu" {
  description = "CPU value for the ECS task"
  type        = string
}

variable "ecs_task_memory" {
  description = "Memory value for the ECS task"
  type        = string
}

variable "network_configuration" {
  description = "The network configuration for the VPC"

  type = object({
    vpc_id          = string,
    private_subnets = list(string),
    public_subnets  = list(string),
  })
}

variable "container_definitions" {
  description = "A list of valid JSON container definitions. By default, the standard definition is used which can be found in 'task-definition.tf' as a locals named default_container_definitions."
  type        = string
  default     = null
}

variable "image" {
  type        = string
  description = "Docker image. This is most often a reference to a container located in a container registry"
  default     = "ghcr.io/runatlantis/atlantis:latest"
}

variable "create_ecs_cluster" {
  description = "Set whether an ECS cluster should be created"
  type        = bool
  default     = true
}

variable "ecs_cluster_name" {
  description = "Name of a self provisioned ECS cluster. Only needs to be set if 'create_ecs_cluster' is set to false"
  type        = string
  default     = ""
}

variable "ecs_cluster_id" {
  description = "ID of a self provisioned ECS cluster. Only needs to be set if 'create_ecs_cluster' is set to false"
  type        = string
  default     = ""
}

variable "ecs_task_definition_role_arn" {
  description = "IAM role ARN used by the ECS task definition. (Currently) Both the execution role and task role are using the same role."
  type        = string
}
