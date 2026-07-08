# terraform/01-network/01-main.tf

# ---------------------------------------------------------
# 1. 네트워크 계층 (VPC 생성)
# ---------------------------------------------------------
# EKS가 동작할 기본 네트워크 환경을 구성
# 퍼블릭/프라이빗 서브넷 분리 (ALB / Node 분리 목적)
module "vpc" {
  source = "../../../modules/vpc"

  name             = "eks-vpc"
  # vpc 네트워크 대역
  cidr             = "10.0.0.0/16"
  # 사용할 AZ (고가용성)
  azs              = ["ap-northeast-2a", "ap-northeast-2c"]
  # EKS 워커 노드 배치되는 private 서브넷
  private_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  # LoadBalancer / NAT 게이트웨이 사용하는 public 서브넷
  public_subnets   = ["10.0.101.0/24", "10.0.102.0/24"]
}