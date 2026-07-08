# 03-platform/01-main.tf

# ---------------------------------------------------------
# 3. 애플리케이션 계층 (nginx 배포)
# ---------------------------------------------------------
# EKS 위에 테스트용 nginx Deployment Service 생성
# LoadBalancer 타입으로 외부 접속 가능하게 구성
module "nginx" {
  source = "../../../modules/nginx"

  # 의존성 ( EKS 먼저 생성 이후 배포되도록 )
  #depends_on = [module.eks]
}

# ---------------------------------------------------------
# 4. Tailscale 설치
# ---------------------------------------------------------
# EKS 생성 후 로컬(mgmt) kubectl + ansible 실행
# Tailsacle subnet router를 k8s 에 설치
module "tailscale" {
  source = "../../../modules/tailscale"

  #cluster_name = module.eks.cluster_name
  cluster_name = data.terraform_remote_state.eks.outputs.cluster_name
  region       = "ap-northeast-2"
  auth_key     = var.tailscale_auth_key
}