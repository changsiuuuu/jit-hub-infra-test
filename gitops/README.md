# GitOps 배포 설정 (`gitops/`)

하이브리드 DR 아키텍처를 기반으로 3개 대상 클러스터(`eks-a`, `eks-b`, `onprem`)에 애플리케이션 및 인프라를 배포하기 위한 ArgoCD 선언식 설정과 환경별 Values 저장소입니다.

## 🏗️ 배포 아키텍처 (Hub & Spoke)
*   **Hub**: 온프레미스 관리용 클러스터 (`mgmt`)에 ArgoCD가 설치되어 동작합니다.
*   **Spoke**: Hub ArgoCD가 아래의 3개 대상 클러스터를 원격 제어합니다.
    1.  `eks-a` (AWS 메인 Active 리전)
    2.  `eks-b` (AWS DR Cold Standby 리전 / Terraform JIT로 스케일업 제어)
    3.  `onprem` (온프레미스 Standby 클러스터 / 메인 DB 인접)

## 📁 하위 디렉터리 구성
1.  [argocd/](file:///home/user1/jit-hub-infra-test/gitops/argocd): 클러스터 등록 정보, 프로젝트 범위 설정, 멀티 클러스터 동적 배포 엔진인 `ApplicationSet` 매니페스트를 관리합니다.
2.  [values/](file:///home/user1/jit-hub-infra-test/gitops/values): 각 클러스터의 특성(Active, Standby, DR)에 대응하는 차트별 오버라이드 설정 값(Values)을 보관합니다.
