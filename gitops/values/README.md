# Helm Values 구성 가이드 (`gitops/values/`)

클러스터별 특성(Active/Standby/DR)과 인프라 목적에 맞춰 Helm Chart에 전달할 파라미터를 관리합니다.

## 📁 디렉터리 구조 및 가이드

```
values/
├── common/
│   └── jit-hub-common.yaml        # 포트, 도메인, 기본 Nginx 등 모든 환경의 공통 설정
├── eks-a/                         # AWS 메인 Active 클러스터 환경
│   ├── jit-hub-values.yaml        # 높은 Replica 수 및 스케일링 설정
│   ├── cloudflared-values.yaml    # replicaCount: 1 (트래픽 수신 상태)
│   ├── monitoring-stack-values.yaml
│   └── ops-values.yaml            # KEDA, Karpenter, Custom Scheduler 활성화
├── eks-b/                         # AWS DR Cold Standby (JIT 복구 타겟) 클러스터 환경
│   ├── jit-hub-values.yaml        # 평시 replicaCount: 0 (Cold)
│   ├── cloudflared-values.yaml    # replicaCount: 0 (트래픽 인입 차단)
│   ├── monitoring-stack-values.yaml
│   └── ops-values.yaml            # Karpenter, KEDA, Custom Scheduler 활성화
└── onprem/                        # 온프레미스 Standby 클러스터 환경
    ├── jit-hub-values.yaml        # 최소 Standby 운영(replica: 1), 로컬 DB 밀착 연동
    ├── cloudflared-values.yaml    # 평시 replicaCount: 0 (Active 장애 시 스크립트로 1 승격)
    ├── monitoring-stack-values.yaml # 통합 Grafana & Loki 구축 (중앙 모니터링 HUB)
    └── ops-values.yaml            # Karpenter/KEDA 비활성화, Custom Scheduler(GreenOps) 활성화
```

## ⚙️ 협업 방식 (수정 가이드)
*   **어플리케이션 버전 배포**: `common/jit-hub-common.yaml`의 `jit-hub-app.image.tag` 값을 변경하고 푸시하면 ArgoCD에 의해 3개 클러스터에 순차적/동시 배포됩니다.
*   **DR 모의훈련 / 실전 Failover**:
    *   장애 복구/트래픽 제어 자동화 스크립트 등을 이용하여 각 클러스터의 `cloudflared-values.yaml` 내 `replicaCount` 설정을 변경(예: eks-a 1->0, onprem 0->1)하고 Push하면 글로벌 라우팅이 우회 조정됩니다.

## 📊 리소스 (CPU/Memory Requests & Limits) 산정 기준
클러스터의 자원 효율성 및 고가용성을 최적화하기 위해, 리전의 역할에 맞추어 Pod 리소스 스펙을 이중화했습니다.

| 환경 | Requests (최소 예약량) | Limits (최대 한계값) | 설계 의도 |
| :--- | :--- | :--- | :--- |
| **`eks-a` / `eks-b`**<br>(AWS Active / DR) | `cpu: 200m`<br>`memory: 256Mi` | `cpu: 1000m` (1 Core)<br>`memory: 1024Mi` (1 GB) | 실시간 대규모 상용 트래픽 대응을 위해 넓은 상한선을 설정하고 스로틀링 및 OOMKilled를 방지합니다. |
| **`onprem`**<br>(Standby) | `cpu: 100m`<br>`memory: 128Mi` | `cpu: 500m` (0.5 Core)<br>`memory: 512Mi` (512 MB) | 평상시 트래픽이 유입되지 않는 대기 서버이므로, 온프레미스 가용 자원을 최소로 소비하도록 다이어트하여 스케일다운합니다. |

*   *주의*: 메모리 사용량이 `Limits` 값을 초과하면 해당 파드는 즉시 `OOMKilled` 상태로 크래시되므로, 성능 측정 및 k6 부하 테스트 진행 시 모니터링 로그 확인이 필요합니다.

## 🗄️ 데이터베이스 연동 설정 주의사항 (`DB_HOST`)
*   **onprem** 환경의 `DB_HOST`는 Kubernetes 내부 루프백 주소(`localhost` 등)가 아닌, **온프레미스 사설 네트워크 대역에 독립적으로 기동 중인 PostgreSQL DB 노드의 사설 IP**를 기입해야 정상적으로 인접 데이터베이스와 통신할 수 있습니다.
