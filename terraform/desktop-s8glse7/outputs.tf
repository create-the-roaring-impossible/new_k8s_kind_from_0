##################################################
# test objects
##################################################

# output "random_integer" { # commented before to use "moved" block
#   value = random_integer.rand.result
# }

output "random_integer" { # decommented before to use "moved" block
  value = random_integer.rand_new.result
}

output "imported_random_integer" { # decommented to test "import" command
  value = random_integer.imported_rand.result
}