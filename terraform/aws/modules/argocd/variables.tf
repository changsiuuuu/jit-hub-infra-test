variable "namespace" {
  description = "ArgoCD namespace"
  type        = string
  default     = "argocd"
}


variable "chart_version" {
  description = "ArgoCD helm chart version"
  type        = string
  default     = "7.7.7"
}


variable "service_type" {
  description = "ArgoCD service type"
  type        = string
  default     = "LoadBalancer"
}