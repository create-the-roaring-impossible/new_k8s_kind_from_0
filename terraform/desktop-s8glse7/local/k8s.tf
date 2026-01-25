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
  # lifecycle {
  #   precondition {
  #     condition = asdasdasd # TODO: to set a condition on "scope" as "ado"
  #     error_message = "Error: you can only set '${var.scope}' as scope"
  #   }
  # }
}