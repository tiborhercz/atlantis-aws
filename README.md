# Terraform AWS ECS cluster for Atlantis

AWS ECS cluster for running the Atlantis application.

## About Atlantis

[Atlantis](https://www.runatlantis.io/guide/) is an application for automating Terraform via pull requests. It is deployed as a standalone application into your infrastructure.

Atlantis listens for GitHub, GitLab or Bitbucket webhooks about Terraform pull requests. It then runs `terraform plan` and comments with the output back on the pull request.

When you want to apply, comment `atlantis apply` on the pull request and Atlantis will run `terraform apply` and comment back with the output.

## Usage

### ECS task role

When using this module it is expected that you bring your own task role.
This can be provided to the module with the `ecs_task_definition_role_arn` variable.

It should have `sts:AssumeRole` Allow with service `ecs-tasks.amazonaws.com`.
The role should also be able to the following actions on the CloudWatch group:
- `logs:CreateLogGroup`
- `logs:CreateLogStream`
- `logs:PutLogEvents`
- `logs:DescribeLogStreams`

The role and policy could look something like this:

```hcl
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
```


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
| [aws_lb.atlantis](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb) | resource |
| [aws_lb_listener.atlantis](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_target_group.atlantis](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |
| [aws_security_group.atlantis_loadbalancer_security_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.atlantis_security_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.atlantis_egress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.atlantis_egress_lb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.atlantis_ingress_atlantis_port](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.atlantis_ingress_http](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cloudwatch_logs_kms_key_id"></a> [cloudwatch\_logs\_kms\_key\_id](#input\_cloudwatch\_logs\_kms\_key\_id) | KMS key ID for CloudWatch Logs encryption. If not set a KMS key will be created and used. | `string` | `null` | no |
| <a name="input_container_definitions"></a> [container\_definitions](#input\_container\_definitions) | A list of valid JSON container definitions. By default, a standard definition is used. | `string` | `""` | no |
| <a name="input_create_ecs_cluster"></a> [create\_ecs\_cluster](#input\_create\_ecs\_cluster) | Set whether an ECS cluster should be created | `bool` | `true` | no |
| <a name="input_ecs_cluster_id"></a> [ecs\_cluster\_id](#input\_ecs\_cluster\_id) | ID of a self provisioned ECS cluster. Only needs to be set if 'create\_ecs\_cluster' is set to false | `string` | `""` | no |
| <a name="input_ecs_cluster_name"></a> [ecs\_cluster\_name](#input\_ecs\_cluster\_name) | Name of a self provisioned ECS cluster. Only needs to be set if 'create\_ecs\_cluster' is set to false | `string` | `""` | no |
| <a name="input_ecs_task_cpu"></a> [ecs\_task\_cpu](#input\_ecs\_task\_cpu) | CPU value for the ECS task | `string` | n/a | yes |
| <a name="input_ecs_task_definition_role_arn"></a> [ecs\_task\_definition\_role\_arn](#input\_ecs\_task\_definition\_role\_arn) | IAM role ARN used by the ECS task definition. (Currently) Both the execution role and task role are using the same role. | `string` | n/a | yes |
| <a name="input_ecs_task_memory"></a> [ecs\_task\_memory](#input\_ecs\_task\_memory) | Memory value for the ECS task | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Used to name the resources | `string` | n/a | yes |
| <a name="input_network_configuration"></a> [network\_configuration](#input\_network\_configuration) | The network configuration for the VPC | <pre>object({<br>    vpc_id          = string,<br>    private_subnets = list(string),<br>    public_subnets  = list(string),<br>  })</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cloudwatch_log_group_atlantis_container_arn"></a> [cloudwatch\_log\_group\_atlantis\_container\_arn](#output\_cloudwatch\_log\_group\_atlantis\_container\_arn) | ARN of the CloudWatch log group for the Atlantis container |
| <a name="output_cloudwatch_log_group_atlantis_container_name"></a> [cloudwatch\_log\_group\_atlantis\_container\_name](#output\_cloudwatch\_log\_group\_atlantis\_container\_name) | Name of the CloudWatch log group for the Atlantis container |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
