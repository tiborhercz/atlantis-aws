# AWS ECS Atlantis external cluster example

The Terraform files in this directory create a fully functional Atlantis ECS cluster.
The ECS cluster itself is created outside the module.

## Usage

Copy the variables from `terraform.tfvars.example` to `terraform.tfvars` and set them to your requirements and preferences.

When the variables are set execute the following commands:
```shell
$ terraform init
$ terraform plan
$ terraform apply
```
