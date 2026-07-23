resource "null_resource" "install_tailscale" {

  triggers = {
    cluster      = var.cluster_name
    manifest_sha = filesha256("${path.module}/../../../../ansible/aws/manifests/tailscale-deployment-prod.yaml")
  }

  provisioner "local-exec" {
    working_dir = path.root

    command = <<EOT
        set -e

        aws eks update-kubeconfig \
          --region ${var.region} \
          --name ${var.cluster_name}

        ansible-playbook \
          -i localhost, \
          -c local \
          ../../../../../ansible/aws/playbook-tailscale.yml \
          --extra-vars "tailscale_auth_key=${var.auth_key} envs=${var.envs}"
        EOT
  }
}
