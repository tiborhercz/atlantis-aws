# Terraform AWS ECS cluster for Atlantis

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.48.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.atlantis](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_group.atlantis_container](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_ecs_cluster.atlantis](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster) | resource |
| [aws_ecs_cluster_capacity_providers.atlantis](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster_capacity_providers) | resource |
| [aws_ecs_service.atlantis](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service) | resource |
| [aws_ecs_task_definition.atlantis](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition) | resource |
| [aws_iam_role.ecs_task](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.ecs_task_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_kms_alias.a](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_key.atlantis](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_lb.atlantis](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb) | resource |
| [aws_lb_listener.atlantis](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_target_group.atlantis](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |
| [aws_security_group.atlantis_security_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.atlantis_egress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.atlantis_ingress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_cloudwatch_log_group.atlantis_container](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/cloudwatch_log_group) | data source |
| [aws_iam_policy_document.ecs_tasks](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.kms_key_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cloudwatch_logs_kms_key_id"></a> [cloudwatch\_logs\_kms\_key\_id](#input\_cloudwatch\_logs\_kms\_key\_id) | KMS key ID for CloudWatch Logs encryption. If not set a KMS key will be created and used. | `string` | `""` | no |
| <a name="input_container_cloudwatch_log_group_name"></a> [container\_cloudwatch\_log\_group\_name](#input\_container\_cloudwatch\_log\_group\_name) | Cloudwatch log group name used by the container definition | `string` | `""` | no |
| <a name="input_container_definitions"></a> [container\_definitions](#input\_container\_definitions) | A list of valid JSON container definitions. By default, a standard definition is used. | `string` | `""` | no |
| <a name="input_create_ecs_cluster"></a> [create\_ecs\_cluster](#input\_create\_ecs\_cluster) | Set whether an ECS cluster should be created | `bool` | `true` | no |
| <a name="input_ecs_cluster_id"></a> [ecs\_cluster\_id](#input\_ecs\_cluster\_id) | ID of a self provisioned ECS cluster. Only needs to be set if 'create\_ecs\_cluster' is set to false | `string` | `""` | no |
| <a name="input_ecs_cluster_name"></a> [ecs\_cluster\_name](#input\_ecs\_cluster\_name) | Name of a self provisioned ECS cluster. Only needs to be set if 'create\_ecs\_cluster' is set to false | `string` | `""` | no |
| <a name="input_ecs_task_cpu"></a> [ecs\_task\_cpu](#input\_ecs\_task\_cpu) | CPU value for the ECS task | `string` | n/a | yes |
| <a name="input_ecs_task_definition_role_arn"></a> [ecs\_task\_definition\_role\_arn](#input\_ecs\_task\_definition\_role\_arn) | IAM role ARN used by the ECS task definition. (Currently) Both the execution role and task role are using the same role. | `string` | `""` | no |
| <a name="input_ecs_task_memory"></a> [ecs\_task\_memory](#input\_ecs\_task\_memory) | Memory value for the ECS task | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Used to name the resources | `string` | n/a | yes |
| <a name="input_network_configuration"></a> [network\_configuration](#input\_network\_configuration) | The network configuration for the VPC | <pre>object({<br>    vpc_id          = string,<br>    private_subnets = list(string),<br>  })</pre> | n/a | yes |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
