resource "random_integer" "rand" {
  min = 1
  max = 100
}

resource "local_file" "test_file" {
  filename = "${random_integer.rand.result}.txt"
  content  = "This is an example file created by Terraform."
}