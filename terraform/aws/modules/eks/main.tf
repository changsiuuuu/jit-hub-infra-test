module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  vpc_id     = var.vpc_id
  subnet_ids = var.subnet_ids

  cluster_endpoint_public_access = true
  enable_irsa                    = true

  enable_cluster_creator_admin_permissions = true

  cluster_addons = {
    coredns    = {}
    kube-proxy = {}
    vpc-cni = {
      configuration_values = jsonencode({
        env = {
          AWS_VPC_K8S_CNI_EXCLUDE_SNAT_CIDRS = "172.16.8.0/24,100.64.0.0/10"
        }
      })
    }
  }

  node_security_group_additional_rules = merge(
    {
      ingress_vpc = {
        description = "VPC traffic"
        protocol    = "-1"
        from_port   = 0
        to_port     = 0
        type        = "ingress"
        cidr_blocks = [var.vpc_cidr]
      }
    },
    var.additional_node_security_group_rules
  )

  eks_managed_node_groups = var.node_groups
}