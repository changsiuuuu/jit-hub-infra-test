# terraform/01-network/00-providers.tf

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.8"
}

provider "aws" {
  region = "ap-northeast-2"
}