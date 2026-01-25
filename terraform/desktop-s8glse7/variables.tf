##################################################
# test variables
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

variable "scope" {
    type = string
    description = "The scope of the project"
    sensitive = false
    default = "default"
    validation {
        condition = length(var.scope) <= 10
        error_message = "error! the length is more than 10 characters."
    }
}