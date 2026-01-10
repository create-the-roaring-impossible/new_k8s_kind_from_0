<!-- BEGIN_TF_DOCS -->
## HEADER

Header test

and even in between sections. also spaces will be preserved:

- item 1
  - item 1-1
- item 2

## Providers

The following providers are used by this module:

- <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) (2.38.0)

- <a name="provider_local"></a> [local](#provider\_local) (2.6.1)

- <a name="provider_random"></a> [random](#provider\_random) (3.7.2)

and they don't even need to be in the default order

## Required Inputs

No required inputs.

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_test_password"></a> [test\_password](#input\_test\_password)

Description: A test password variable

Type: `string`

Default: `"1234567890ab"`

## Outputs

The following outputs are exported:

### <a name="output_imported_random_integer"></a> [imported\_random\_integer](#output\_imported\_random\_integer)

Description: n/a

### <a name="output_random_integer"></a> [random\_integer](#output\_random\_integer)

Description: n/a

## FOOTER

Footer test
<!-- END_TF_DOCS -->