# 모듈 테스트 결과

이 문서는 Terraform 모듈 테스트 결과를 기록합니다.

## 테스트 요약

| 모듈명 | 테스트 상태 | 테스트 일시 | 비고 |
|--------|-------------|-------------|------|
| ECS Service | ✅ 통과 | 2025-11-04 | deployment_configuration 구조 수정 후 통과 |
| ECR | ✅ 통과 | 2025-11-04 | 최초 테스트 통과 |

---

## 1. ECS Service 모듈 테스트

### 테스트 정보
- **테스트 일시**: 2025-11-04
- **테스트 모듈**: ECS Service
- **모듈 경로**: `infra/dev/modules/ecs/ecs-service`
- **테스트 파일**: [tests/ecs-service-test/main.tf](ecs-service-test/main.tf)

### 테스트 결과
✅ **통과**

### 테스트 과정

#### 1차 테스트 - 실패
```bash
cd tests/ecs-service-test
terraform init
terraform validate
```

**오류 메시지:**
```
Error: Unsupported argument
on ../../infra/dev/modules/ecs/ecs-service/main.tf line 39
An argument named "maximum_percent" is not expected here.
```

#### 발견된 이슈
`deployment_configuration` 블록 구조가 AWS Provider의 ECS Service 리소스 스키마와 불일치

**문제 코드:**
```hcl
deployment_configuration {
  maximum_percent         = var.deployment_configuration.maximum_percent
  minimum_healthy_percent = var.deployment_configuration.minimum_healthy_percent

  deployment_circuit_breaker {
    enable   = var.deployment_configuration.deployment_circuit_breaker.enable
    rollback = var.deployment_configuration.deployment_circuit_breaker.rollback
  }
}
```

#### 수정 내용
[infra/dev/modules/ecs/ecs-service/main.tf:38](../infra/dev/modules/ecs/ecs-service/main.tf#L38)

**수정 후 코드:**
```hcl
deployment_controller {
  type = "ECS"
}

deployment_circuit_breaker {
  enable   = var.deployment_configuration.deployment_circuit_breaker.enable
  rollback = var.deployment_configuration.deployment_circuit_breaker.rollback
}

deployment_maximum_percent         = var.deployment_configuration.maximum_percent
deployment_minimum_healthy_percent = var.deployment_configuration.minimum_healthy_percent
```

#### 2차 테스트 - 통과
```bash
terraform validate
# ✅ Success! The configuration is valid.

terraform plan
# ✅ Plan: 1 to add, 0 to change, 0 to destroy.
```

### 검증 방법
- `terraform init`: 모듈 다운로드 및 Provider 설치
- `terraform validate`: HCL 구문 및 설정 유효성 검사
- `terraform plan`: 실행 계획 생성 (리소스 생성 없이 dry-run)

### 생성 예정 리소스
```hcl
# module.aws_ecs_service.aws_ecs_service.this
resource "aws_ecs_service" "this" {
  cluster                            = "arn:aws:ecs:ap-northeast-2:123456789012:cluster/test"
  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100
  desired_count                      = 1
  enable_execute_command             = true
  launch_type                        = "FARGATE"
  platform_version                   = "LATEST"

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  network_configuration {
    assign_public_ip = true
    security_groups  = ["sg-xxx"]
    subnets          = ["subnet-xxx"]
  }
}
```

---

## 2. ECR 모듈 테스트

### 테스트 정보
- **테스트 일시**: 2025-11-04
- **테스트 모듈**: ECR (Elastic Container Registry)
- **모듈 경로**: `infra/dev/modules/ecr`
- **테스트 파일**: [tests/ecr-test/main.tf](ecr-test/main.tf)

### 테스트 결과
✅ **통과** (최초 테스트 통과)

### 테스트 과정

```bash
# 1. 테스트 디렉토리 생성
mkdir -p tests/ecr-test

# 2. 테스트 파일 작성
# tests/ecr-test/main.tf

# 3. Terraform 초기화
cd tests/ecr-test
terraform init
# ✅ Terraform has been successfully initialized!

# 4. 구문 검증
terraform validate
# ✅ Success! The configuration is valid.

# 5. 실행 계획 확인
terraform plan
# ✅ Plan: 1 to add, 0 to change, 0 to destroy.
```

### 검증 방법
- `terraform init`: 모듈 다운로드 및 Provider 설치
- `terraform validate`: HCL 구문 및 설정 유효성 검사
- `terraform plan`: 실행 계획 생성 (리소스 생성 없이 dry-run)

### 생성 예정 리소스
```hcl
# module.aws_ecr.aws_ecr_repository.this
resource "aws_ecr_repository" "this" {
  arn                  = (known after apply)
  id                   = (known after apply)
  image_tag_mutability = "MUTABLE"
  name                 = "test-ecr-repo"
  region               = "ap-northeast-2"
  registry_id          = (known after apply)
  repository_url       = (known after apply)
  tags                 = {
    "Environment" = "test"
    "ManagedBy"   = "Terraform"
    "Project"     = "test"
  }
  tags_all             = {
    "Environment" = "test"
    "ManagedBy"   = "Terraform"
    "Project"     = "test"
  }

  image_scanning_configuration {
    scan_on_push = true
  }
}
```

### 검증 항목
- ✅ ECR Repository 리소스 생성
- ✅ image_tag_mutability: MUTABLE 설정
- ✅ scan_on_push: true (이미지 스캔 활성화)
- ✅ 태그 적용 (Environment, Project, ManagedBy)
- ✅ 출력 값 (repository_url, repository_arn)

### 발견된 이슈
없음 (최초 테스트 통과)

---

## 테스트 대기 모듈

다음 모듈들은 아직 테스트가 진행되지 않았습니다:

- [ ] ECS Cluster 모듈 (`infra/dev/modules/ecs/ecs-cluster`)
- [ ] ECS Task Definition 모듈 (`infra/dev/modules/ecs/ecs-task-definition`)
- [ ] Security Group 모듈 (`infra/dev/modules/security-group`)
- [ ] Target Group 모듈 (`infra/dev/modules/target-group`)
- [ ] Common 모듈 (`infra/dev/modules/common`)

---

## 테스트 모범 사례

### 1. 모듈 경로 설정
```hcl
# ✅ 올바른 경로 (infra/ 하위)
source = "../../infra/dev/modules/ecr"

# ❌ 잘못된 경로
source = "../../dev/modules/ecr"  # infra/ 누락
```

### 2. 더미 값 사용
테스트 시 실제 AWS 리소스 ARN이 필요하지 않은 경우 더미 값 사용:
```hcl
cluster_id          = "arn:aws:ecs:ap-northeast-2:123456789012:cluster/test"
task_definition_arn = "arn:aws:ecs:ap-northeast-2:123456789012:task-definition/test:1"
subnets             = ["subnet-xxx"]
security_groups     = ["sg-xxx"]
```

### 3. 필수 변수만 설정
테스트 시 선택적 변수는 모듈의 기본값 사용:
```hcl
module "test" {
  source = "..."

  # 필수 변수만 설정
  repository_name = "test-repo"

  # 선택적 변수는 기본값 사용 (명시 불필요)
}
```

### 4. 반복 테스트
모듈 수정 후 즉시 테스트 실행하여 회귀 방지:
```bash
# 모듈 수정 후
cd tests/{module-name}-test
terraform init      # 모듈 업데이트
terraform validate  # 구문 검증
terraform plan      # 동작 검증
```

---

## 향후 테스트 계획

### 1. 통합 테스트
여러 모듈을 조합한 통합 테스트 작성:
```
tests/
└── integration-test/
    └── ecs-full-stack-test/  # Cluster + Task Definition + Service
```

### 2. 자동화 테스트
CI/CD 파이프라인에 테스트 자동 실행 통합:
```bash
#!/bin/bash
# test-all-modules.sh
for test_dir in tests/*/; do
  cd "$test_dir"
  terraform init -upgrade
  terraform validate || exit 1
  terraform plan || exit 1
  cd -
done
```

### 3. 실제 배포 테스트
개발 환경에 실제 리소스 배포 후 동작 확인:
```bash
# 주의: 실제 AWS 리소스 생성 (비용 발생)
terraform apply -auto-approve
# 테스트 후 정리
terraform destroy -auto-approve
```
