# TODO - 프로젝트 개선 작업 목록

## 🚨 즉시 조치 필요 (Critical)

### 1. .gitignore 개선 - 민감 정보 보호
**우선순위**: ⚠️ 최상
**상태**: ❌ 미완료
**담당**: -
**기한**: 즉시

**현재 문제**:
- `*.tfvars` 파일이 git에 포함될 위험
- `*.tfstate` 파일 누락 (민감 정보 포함)
- 백업 파일, 로그 파일 등 제외 안됨

**조치 내용**:
```gitignore
# Local .terraform directories
**/.terraform/*

# .tfstate files
*.tfstate
*.tfstate.*

# Crash log files
crash.log
crash.*.log

# Exclude all .tfvars files (민감 정보 보호)
*.tfvars
!*.tfvars.example

# Ignore override files
override.tf
override.tf.json
*_override.tf
*_override.tf.json

# Ignore CLI configuration files
.terraformrc
terraform.rc

# Ignore Mac .DS_Store files
.DS_Store

# Ignore local env files
.env
.env.*

# Ignore backup files
*.backup
*.bak

# Ignore IDE files
.vscode/
.idea/
*.swp
*.swo
*~
```

**완료 조건**:
- [ ] .gitignore 파일 업데이트
- [ ] 기존 git history에서 민감 정보 제거 확인
- [ ] `git status`로 .tfvars 파일이 untracked 확인

---

### 2. Git에서 민감 정보 제거 확인
**우선순위**: ⚠️ 최상
**상태**: ❌ 미완료
**담당**: -
**기한**: 즉시

**조치 내용**:
```bash
# git history에 .tfvars 파일이 있는지 확인
git log --all --full-history --oneline -- "*.tfvars"

# 만약 있다면 제거 (조심스럽게!)
# git filter-branch 또는 BFG Repo-Cleaner 사용
```

**완료 조건**:
- [ ] git history 확인 완료
- [ ] 민감 정보가 있었다면 제거 완료
- [ ] .gitignore 적용 확인

---

## 📋 단기 조치 (High Priority)

### 3. 각 모듈에 README.md 추가
**우선순위**: 🔴 높음
**상태**: ❌ 미완료
**담당**: -
**기한**: 1주일 이내

**필요한 README 파일**:
- [ ] `modules/ec2/README.md`
- [ ] `modules/ecs/cluster/README.md`
- [ ] `modules/ecs/task-definition/README.md`
- [ ] `modules/ecs/service/README.md`
- [ ] `modules/ecs/autoscaling/README.md`

**README 표준 구조**:
```markdown
# [모듈 이름]

## 개요
[모듈 설명]

## 사용 예시

\`\`\`hcl
module "example" {
  source = "../../modules/..."

  # 필수 변수
  ...
}
\`\`\`

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.9.0 |
| aws | ~> 5.57 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| ... | ... | ... | ... | yes/no |

## Outputs

| Name | Description |
|------|-------------|
| ... | ... |

## 참고사항
[추가 설명]
```

**완료 조건**:
- [ ] 모든 모듈에 README.md 파일 생성
- [ ] 각 README에 사용 예시 포함
- [ ] Input/Output 테이블 완성

---

### 4. 각 모듈에 versions.tf 추가
**우선순위**: 🔴 높음
**상태**: ❌ 미완료
**담당**: -
**기한**: 1주일 이내

**필요한 파일**:
- [ ] `modules/ec2/versions.tf`
- [ ] `modules/ecs/cluster/versions.tf`
- [ ] `modules/ecs/task-definition/versions.tf`
- [ ] `modules/ecs/service/versions.tf`
- [ ] `modules/ecs/autoscaling/versions.tf`

**템플릿**:
```hcl
terraform {
  required_version = ">= 1.9.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.18.0"
    }
  }
}
```

**완료 조건**:
- [ ] 모든 모듈에 versions.tf 추가
- [ ] Terraform 및 Provider 버전 명시

---

### 5. Variable Validation 추가
**우선순위**: 🔴 높음
**상태**: ❌ 미완료
**담당**: -
**기한**: 2주일 이내

**대상 변수**:
- [ ] `cpu` - 유효한 값만 허용 (256, 512, 1024, 2048, 4096)
- [ ] `memory` - CPU에 따라 유효한 메모리 값
- [ ] `env` - dev, stage, prod만 허용
- [ ] `container_port` - 1-65535 범위
- [ ] `desired_count` - 최소 0 이상
- [ ] `min_capacity`, `max_capacity` - min <= max 검증

**예시**:
```hcl
variable "cpu" {
  type        = string
  description = "Task CPU units"

  validation {
    condition     = contains(["256", "512", "1024", "2048", "4096"], var.cpu)
    error_message = "CPU must be one of: 256, 512, 1024, 2048, 4096"
  }
}

variable "env" {
  type        = string
  description = "Environment"

  validation {
    condition     = contains(["dev", "stage", "prod"], var.env)
    error_message = "Environment must be one of: dev, stage, prod"
  }
}
```

**완료 조건**:
- [ ] 주요 변수에 validation 추가
- [ ] 에러 메시지가 명확하고 한국어로 작성
- [ ] terraform plan으로 validation 테스트

---

## 🔧 중기 조치 (Medium Priority)

### 6. Backend 설정 (S3 + DynamoDB)
**우선순위**: 🟡 중간
**상태**: ❌ 미완료
**담당**: -
**기한**: 1개월 이내

**작업 내용**:
1. S3 버킷 생성 (State 저장용)
2. DynamoDB 테이블 생성 (State Lock용)
3. Backend 설정 파일 작성

**파일 구조**:
```
backend-config/
├── dev.hcl
├── stage.hcl
└── prod.hcl
```

**backend.tf 예시**:
```hcl
terraform {
  backend "s3" {
    # 환경별로 다른 설정 사용
    # terraform init -backend-config=backend-config/dev.hcl
  }
}
```

**dev.hcl 예시**:
```hcl
bucket         = "nextpay-terraform-state-dev"
key            = "cms/terraform.tfstate"
region         = "ap-northeast-2"
encrypt        = true
dynamodb_table = "nextpay-terraform-lock-dev"
```

**완료 조건**:
- [ ] S3 버킷 생성 (버저닝, 암호화 활성화)
- [ ] DynamoDB 테이블 생성
- [ ] 환경별 backend 설정 파일 작성
- [ ] State 마이그레이션 테스트

---

### 7. 환경별 디렉토리 구조 구축
**우선순위**: 🟡 중간
**상태**: ❌ 미완료
**담당**: -
**기한**: 1개월 이내

**목표 구조**:
```
envs/
├── dev/
│   ├── backend.hcl
│   ├── terraform.tfvars
│   └── main.tf
├── stage/
│   ├── backend.hcl
│   ├── terraform.tfvars
│   └── main.tf
└── prod/
    ├── backend.hcl
    ├── terraform.tfvars
    └── main.tf
```

**main.tf 예시**:
```hcl
module "cms" {
  source = "../../solutions/cms"

  # terraform.tfvars에서 변수 주입
  project = var.project
  env     = var.env
  ...
}
```

**완료 조건**:
- [ ] envs/ 디렉토리 생성
- [ ] 각 환경별 설정 파일 작성
- [ ] 환경 간 차이점 명확히 분리

---

### 8. locals.tf 도입으로 코드 중복 제거
**우선순위**: 🟡 중간
**상태**: ❌ 미완료
**담당**: -
**기한**: 1개월 이내

**대상 파일**:
- [ ] `solutions/cms/locals.tf`
- [ ] 각 모듈에 필요 시 추가

**예시**:
```hcl
# solutions/cms/locals.tf
locals {
  name_prefix = "${var.project}-${var.env}"

  common_tags = {
    Project     = var.project
    Environment = var.env
    ManagedBy   = "terraform"
    Solution    = "cms"
    CreatedAt   = timestamp()
  }

  # 컨테이너 환경 변수 그룹화
  app_env_vars = {
    NODE_ENV = var.env
    PORT     = var.container_port
    LOG_LEVEL = var.env == "prod" ? "warn" : "info"
  }
}
```

**완료 조건**:
- [ ] 반복되는 표현식을 locals로 추출
- [ ] 태그를 locals.common_tags로 통일
- [ ] 조건부 로직을 locals에 정리

---

### 9. 모듈 출력값 활용도 개선
**우선순위**: 🟡 중간
**상태**: ❌ 미완료
**담당**: -
**기한**: 1개월 이내

**추가 필요한 출력값**:
- [ ] ECS Service의 `desired_count`, `running_count`
- [ ] Task Definition의 `container_definitions` (JSON)
- [ ] Auto Scaling의 policy ARN 목록
- [ ] Cluster의 `capacity_providers`

**예시**:
```hcl
# modules/ecs/service/outputs.tf
output "desired_count" {
  value       = aws_ecs_service.this.desired_count
  description = "Desired task count"
}

output "running_count" {
  value       = aws_ecs_service.this.running_count
  description = "Current running task count"
}
```

**완료 조건**:
- [ ] 필요한 출력값 추가
- [ ] 모든 출력값에 description 있음
- [ ] 솔루션 레벨에서 유용한 정보 출력

---

## 🔄 장기 조치 (Low Priority)

### 10. 테스트 코드 작성
**우선순위**: 🟢 낮음
**상태**: ❌ 미완료
**담당**: -
**기한**: 3개월 이내

**테스트 프레임워크**: Terratest (Go) 또는 Terraform Test

**디렉토리 구조**:
```
tests/
├── modules/
│   ├── ec2_test.go
│   └── ecs/
│       ├── cluster_test.go
│       ├── task_definition_test.go
│       ├── service_test.go
│       └── autoscaling_test.go
└── solutions/
    └── cms_test.go
```

**테스트 항목**:
- [ ] 모듈이 정상적으로 리소스 생성하는지
- [ ] 변수 validation이 작동하는지
- [ ] 출력값이 올바른지
- [ ] 태그가 제대로 적용되는지

**완료 조건**:
- [ ] 주요 모듈에 테스트 코드 작성
- [ ] CI에서 자동 테스트 실행
- [ ] 테스트 커버리지 80% 이상

---

### 11. CI/CD 파이프라인 구축
**우선순위**: 🟢 낮음
**상태**: ❌ 미완료
**담당**: -
**기한**: 3개월 이내

**도구**: GitHub Actions

**워크플로우**:
```yaml
# .github/workflows/terraform.yml
name: Terraform CI/CD

on:
  pull_request:
    branches: [main]
  push:
    branches: [main]

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: hashicorp/setup-terraform@v2
      - run: terraform init
      - run: terraform validate
      - run: terraform fmt -check

  plan:
    needs: validate
    runs-on: ubuntu-latest
    steps:
      - run: terraform plan

  apply:
    needs: plan
    if: github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    steps:
      - run: terraform apply -auto-approve
```

**완료 조건**:
- [ ] PR 시 자동 validate, plan
- [ ] main 브랜치 merge 시 자동 apply (옵션)
- [ ] Terraform Cloud 또는 Atlantis 연동 검토

---

### 12. 보안 강화
**우선순위**: 🟢 낮음
**상태**: ❌ 미완료
**담당**: -
**기한**: 3개월 이내

**개선 항목**:
- [ ] AWS Secrets Manager 연동
- [ ] 환경 변수 암호화
- [ ] IAM Policy 최소 권한 원칙 적용
- [ ] Security Group 규칙 최소화
- [ ] KMS 암호화 적용

**Secrets Manager 예시**:
```hcl
data "aws_secretsmanager_secret_version" "db_password" {
  secret_id = "cms-db-password-${var.env}"
}

locals {
  db_password = jsondecode(data.aws_secretsmanager_secret_version.db_password.secret_string)["password"]
}
```

**완료 조건**:
- [ ] 민감 정보를 Secrets Manager로 이동
- [ ] IAM Policy 최소 권한 검토
- [ ] 보안 스캔 도구 적용 (tfsec, checkov)

---

### 13. 모니터링 및 알람 설정
**우선순위**: 🟢 낮음
**상태**: ❌ 미완료
**담당**: -
**기한**: 3개월 이내

**구성 요소**:
- [ ] CloudWatch Dashboard 모듈
- [ ] SNS Topic 및 알람 모듈
- [ ] X-Ray 트레이싱 설정
- [ ] Container Insights 활성화

**모듈 구조**:
```
modules/
├── monitoring/
│   ├── dashboard/
│   ├── alarms/
│   └── sns/
```

**완료 조건**:
- [ ] ECS 서비스 메트릭 대시보드
- [ ] CPU/Memory 임계값 알람
- [ ] SNS로 알람 전송
- [ ] 로그 보존 정책 설정

---

### 14. 문서화 개선
**우선순위**: 🟢 낮음
**상태**: ❌ 미완료
**담당**: -
**기한**: 지속적

**추가 필요 문서**:
- [ ] `docs/architecture.md` - 아키텍처 다이어그램
- [ ] `docs/deployment.md` - 배포 가이드
- [ ] `docs/troubleshooting.md` - 트러블슈팅 가이드
- [ ] `docs/runbook.md` - 운영 가이드
- [ ] `CONTRIBUTING.md` - 기여 가이드

**완료 조건**:
- [ ] 모든 문서가 최신 상태 유지
- [ ] 다이어그램 추가 (draw.io, mermaid)
- [ ] FAQ 섹션 추가

---

## 📊 진행 상황 추적

### 전체 진행률
- 즉시 조치: 0/2 (0%)
- 단기 조치: 0/4 (0%)
- 중기 조치: 0/5 (0%)
- 장기 조치: 0/5 (0%)

**총 진행률**: 0/16 (0%)

---

## 🎯 다음 주 목표

1. ✅ .gitignore 개선
2. ✅ Git history에서 민감 정보 확인
3. ✅ 모든 모듈에 README.md 추가
4. ✅ 모든 모듈에 versions.tf 추가

---

## 📝 작업 로그

### 2025-10-27
- ❌ TODO.md 파일 생성
- ⏳ 작업 대기 중

---

## 💡 참고 자료

- [Terraform Module Best Practices](https://www.terraform.io/docs/modules/index.html)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Terraform Testing](https://www.terraform.io/docs/language/modules/testing.html)
- [HashiCorp Configuration Language Style Guide](https://www.terraform.io/docs/language/syntax/style.html)

---

**마지막 업데이트**: 2025-10-27
