<!-- BEGIN_TF_DOCS -->
# Documentation

and even in between sections. also spaces will be preserved:

- item 1
  - item 1-1
- item 2

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | 6.2.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | 4.52.0 |
| <a name="requirement_google"></a> [google](#requirement\_google) | 7.10.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | 2.38.0 |
| <a name="requirement_local"></a> [local](#requirement\_local) | 2.6.1 |
| <a name="requirement_random"></a> [random](#requirement\_random) | 3.7.2 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | 2.38.0 |
| <a name="provider_local"></a> [local](#provider\_local) | 2.6.1 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.7.2 |

and they don't even need to be in the default order

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_test_password"></a> [test\_password](#input\_test\_password) | A test password variable | `string` | `"1234567890ab"` | no |

## Resources

| Name | Type |
|------|------|
| [kubernetes_namespace.gh_ns](https://registry.terraform.io/providers/hashicorp/kubernetes/2.38.0/docs/resources/namespace) | resource |
| [local_file.test_file](https://registry.terraform.io/providers/hashicorp/local/2.6.1/docs/resources/file) | resource |
| [local_file.test_file_heredoc](https://registry.terraform.io/providers/hashicorp/local/2.6.1/docs/resources/file) | resource |
| [random_integer.imported_rand](https://registry.terraform.io/providers/hashicorp/random/3.7.2/docs/resources/integer) | resource |
| [random_integer.rand_new](https://registry.terraform.io/providers/hashicorp/random/3.7.2/docs/resources/integer) | resource |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_imported_random_integer"></a> [imported\_random\_integer](#output\_imported\_random\_integer) | n/a |
| <a name="output_random_integer"></a> [random\_integer](#output\_random\_integer) | n/a |



The End ;-)
<!-- END_TF_DOCS -->