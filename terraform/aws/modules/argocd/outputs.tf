output "namespace" {
  value = var.namespace
}


output "release_name" {
  value = helm_release.argocd.name
}


output "status" {
  value = helm_release.argocd.status
}