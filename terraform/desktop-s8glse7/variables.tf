##################################################
# test objects
##################################################

variable "test_password" {
    type = string
    description = "A test password variable"
    sensitive = true
    default = "1234567890ab"
    validation {
        condition = length(var.test_password) >= 12
        error_message = "error! the length is less than 12 characters."
    }
}