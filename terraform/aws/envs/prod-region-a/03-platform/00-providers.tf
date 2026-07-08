# 03-platform/00-providers.tf

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.30"
    }
  }
}

provider "aws" {
  region = "ap-northeast-2"
}

provider "kubernetes" {
  #host = module.eks.cluster_endpoint
  host = data.terraform_remote_state.eks.outputs.cluster_endpoint

  cluster_ca_certificate = base64decode(
    #module.eks.cluster_certificate_authority_data
    data.terraform_remote_state.eks.outputs.cluster_certificate_authority_data
  )

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    /*
    args = [
      "eks",
      "get-token",
      "--cluster-name",
      module.eks.cluster_name,
      "--region",
      "ap-northeast-2"
    ]
    */
    args = [
      "eks",
      "get-token",
      "--cluster-name",
      data.terraform_remote_state.eks.outputs.cluster_name,
      "--region",
      "ap-northeast-2"
    ]    
  }
}

data "terraform_remote_state" "eks" {

  backend = "local"

  config = {
    path = "../02-eks/terraform.tfstate"
  }

}