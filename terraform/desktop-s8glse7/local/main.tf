resource "local_file" "test_file" {
  filename = "test.txt"
  content  = "This is an example file created by Terraform."
}