variable "name" {
  description = "Used to name the resources"
  type = string
}

variable "logs_kms_key_id" {
  description = "KMS key ID for CloudWatch Logs encryption"
  type = string
}

variable "ecs_task_cpu" {
  description = "CPU value for the ECS task"
  type = string
}

variable "ecs_task_memory" {
  description = "Memory value for the ECS task"
  type = string
}

# VPC
variable "cidr" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = ""
}

variable "azs" {
  description = "A list of availability zones in the region"
  type        = list(string)
  default     = []
}

variable "private_subnets" {
  description = "A list of subnets in the VPC"
  type        = list(string)
  default     = []
}

variable "public_subnets" {
  description = "A list of public subnets in the VPC"
  type        = list(string)
  default     = []
}
