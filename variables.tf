variable "name" {
  description = "Used to name the resources"
  type        = string
}

variable "logs_kms_key_id" {
  description = "KMS key ID for CloudWatch Logs encryption. If not set a KMS key will be created and used."
  type        = string
  default     = ""
}

variable "ecs_task_cpu" {
  description = "CPU value for the ECS task"
  type        = string
}

variable "ecs_task_memory" {
  description = "Memory value for the ECS task"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "private_subnets" {
  description = "Private subnets"
  type        = list(string)
}

variable "container_definitions" {
  description = "A list of valid JSON container definitions. By default, a standard definition is used."
  type        = string
  default     = ""
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
