# Terraform 가이드

### 설정파일 추가 (tailscale_auth_key)
```
# 경로
> jit-hub-infra/terraform/aws/envs/prod-region-a/03-platform/terraform.tfvars
```
```
# 03-platform/terraform.tfvars
tailscale_auth_key = ""
```

### terraform 실행 스크립트 권한부여
```
# 경로
jit-hub-infra/terraform/aws/envs/prod-region-a

> chmod +x deploy.sh
> chmod +x destroy.sh
```

### terraform 실행
```
# 경로
> jit-hub-infra/terraform/aws/envs/prod-region-a

# apply 스크립트 실행
> ./deply.sh

    01-network > 02-eks > 03-platform

# destroy 스크립트 실행
> ./destroy.sh

    03-platform > 02-eks > 01-network
    역순으로 destroy
```







