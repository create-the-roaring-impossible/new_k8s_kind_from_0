# resource "random_integer" "rand" { # commented before to use "moved" block
#   min = 1
#   max = 100
# }

# moved { # comment "random_integer.rand" and decomment "random_integer.rand_new", before to use it (and comment it after resource moving)
#   from = random_integer.rand
#   to   = random_integer.rand_new
# }

resource "random_integer" "rand_new" { # decommented before to use "moved" block
  min = 1
  max = 100
}

resource "local_file" "test_file" {
  filename = "${random_integer.rand_new.result}.txt"
  content  = "This is an example file created by Terraform."
}

resource "local_file" "test_file_heredoc" {
  filename = "heredoc.txt"
  content  = <<-EOF
This is an example file created by Terraform.
test line
test line
test line
  EOF
}

resource "local_file" "test_template_file" {
  filename = "templates/template_test.txt"
  content  = "# template test"
}