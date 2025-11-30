resource "random_integer" "rand" {
  min = 1
  max = 100
}

resource "local_file" "test_file" { # commented to test "state mv" command
  filename = "${random_integer.rand.result}.txt"
  content  = "This is an example file created by Terraform."
}

# moved {
#   from = random_integer.rand
#   to  = random_integer.rand_new
# }

# resource "local_file" "test_file_new" {
#   filename = "${random_integer.rand.result}.txt"
#   content  = "This is an example file created by Terraform."
# }

resource "local_file" "test_1_file" {
  filename = "heredoc.txt"
  content  = <<-EOF
This is an example file created by Terraform.
test line
test line
test line
  EOF
}