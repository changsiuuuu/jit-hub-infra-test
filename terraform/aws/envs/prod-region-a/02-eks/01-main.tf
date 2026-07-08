# terraform/02-eks/01-main.tf

# ---------------------------------------------------------
# 2. 인프라 계층 (EKS 클러스터 생성)
# ---------------------------------------------------------
module "eks" {
  source = "../../../modules/eks"

  # 클러스터 이름
  cluster_name    = "hello-eks"
  # k8s 버전
  cluster_version = "1.31"

  # -------------------------------------------------------
  # Network (01-network terraform state 참조)
  # -------------------------------------------------------
  vpc_id = data.terraform_remote_state.network.outputs.vpc_id
  subnet_ids = data.terraform_remote_state.network.outputs.private_subnets
  vpc_cidr = data.terraform_remote_state.network.outputs.vpc_cidr

  # VPC 연결
  #vpc_id     = module.vpc.vpc_id
  #subnet_ids = module.vpc.private_subnets
  #vpc_cidr   = "10.0.0.0/16"  # 네트워크 보안 정책용 CIDR

  # 워커 노드 그룹 설정
  node_groups = {
    default = {
      #instance_types = ["t3.medium"]
      instance_types = ["t3.small"]
      ami_type       = "AL2_x86_64"
      min_size       = 1    # 최소노드 수
      max_size       = 4    # 최대노드 수
      desired_size   = 2    # 기본노드 수

    #   iam_role_additional_policies = {
    #     AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    #   }

    }
  }
}


