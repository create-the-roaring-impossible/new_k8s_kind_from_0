##################################################
# test objects
##################################################

resource "kubernetes_namespace" "ns" {
  metadata {
    annotations = {
      name = "${var.scope}-annotation"
    }
    labels = {
      mylabel = "${var.scope}-label"
    }
    name = "${var.scope}-ns"
  }
  wait_for_default_service_account = true
  lifecycle {
    precondition {
      condition = var.scope == "gh"
      error_message = "Error: you can only set 'gh' as scope"
    }
    postcondition {
      condition = self.metadata.annotations.name != ""
      error_message = "Error: namespace created without annotation name"
    }
  }
}