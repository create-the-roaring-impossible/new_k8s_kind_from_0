# output "random_integer" { # commented before to use "moved" block
#   value = random_integer.rand.result
# }

output "random_integer" { # decommented before to use "moved" block
  value = random_integer.rand_new.result
}