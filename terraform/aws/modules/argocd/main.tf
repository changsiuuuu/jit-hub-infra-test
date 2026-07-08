resource "helm_release" "argocd" {

  name = "argocd"

  namespace = var.namespace

  create_namespace = true


  repository = "https://argoproj.github.io/argo-helm"

  chart = "argo-cd"

  version = var.chart_version


  values = [
    yamlencode({

      server = {

        service = {

          type = "LoadBalancer"

        }


        extraArgs = [
          "--insecure"
        ]

      }

    })
  ]
}