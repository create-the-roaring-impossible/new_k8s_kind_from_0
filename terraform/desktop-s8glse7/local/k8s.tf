##################################################
# test objects
##################################################

resource "kubernetes_namespace" "gh_ns" {
  metadata {
    annotations = {
      name = "gh-annotation"
    }
    labels = {
      mylabel = "gh-label"
    }
    name = "gh-ns"
  }
  wait_for_default_service_account = true
}