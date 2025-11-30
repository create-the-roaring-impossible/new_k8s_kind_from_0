resource "random_integer" "rand" {
  min = 1
  max = 100
}

resource "local_file" "test_file" {
  filename = "${random_integer.rand.result}.txt"
  content  = "This is an example file created by Terraform."
}

# moved {
#   from = random_integer.rand
#   to  = random_integer.rand_new
# }

# resource "random_integer" "rand_new" {
#   min = 1
#   max = 100
# }

# resource "local_file" "test_0_file" {
#   filename = "${random_integer.rand_new.result}.txt"
#   content  = "This is an example file created by Terraform."
# }

# resource "local_file" "test_1_file" {
#   filename = "heredoc.txt"
#   content  = <<-EOF
# This is an example file created by Terraform.
# test line
# test line
# test line
#   EOF
# }