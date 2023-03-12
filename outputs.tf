output "cloudwatch_log_group_atlantis_container_arn" {
  description = "ARN of the CloudWatch log group for the Atlantis container"
  value       = aws_cloudwatch_log_group.atlantis_container.arn
}

output "cloudwatch_log_group_atlantis_container_name" {
  description = "Name of the CloudWatch log group for the Atlantis container"
  value       = aws_cloudwatch_log_group.atlantis_container.name
}
