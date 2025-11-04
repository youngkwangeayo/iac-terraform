# 작업 이력

## 2025-11-04: 프로젝트 구조 정리 및 README 개선

### 수행한 작업

#### 1. 프로젝트 디렉토리 구조 생성
기존 README.md에 명시된 디렉토리 구조를 실제로 구현했습니다.

**생성된 디렉토리 구조:**
```
tf-aws-module/
├── dev/
│   ├── modules/          # 재사용 가능한 모듈
│   │   ├── network/
│   │   ├── ec2/
│   │   └── ecs/
│   ├── network/          # 루트 모듈
│   ├── computing/        # 루트 모듈
│   └── projects/         # 프로젝트별 배포 루트 모듈
│
└── prod/                 # dev와 동일한 구조
    ├── modules/
    ├── network/
    ├── computing/
    └── projects/
```

#### 2. README.md 문서 개선

**개선 사항:**

1. **전체 목표 섹션 정리**
   - 문장 구조를 명확하게 개선
   - 마이그레이션 전략을 별도 섹션으로 분리하여 가독성 향상
   - 핵심 개념을 bullet point로 명확히 정리

2. **단계별 목표 구조화**
   - 기존의 불명확한 목표를 Phase 1, Phase 2로 구조화
   - 각 Phase별 구체적인 작업 항목 명시

3. **디렉토리 구조 상세화**
   - 각 디렉토리의 역할을 주석으로 명확히 설명
   - 파일 구조를 더 상세하게 표시 (main.tf, variables.tf, outputs.tf, backend.tf)
   - State 관리 및 참조 관계를 주석으로 명시
   - 실제 프로젝트 구조에 맞게 수정

4. **Terraform 모범사례 섹션 확장**
   - 기존의 간단한 bullet point를 3개의 서브섹션으로 확장
   - **모듈 개발 원칙**: 네이밍, 설계 원칙, 단일 책임, 인터페이스 정의
   - **State 관리**: Backend 설정, State 격리, State 참조 방법
   - **환경 관리**: 환경 분리, 공통 코드 재사용, 환경별 설정 방법

5. **작업 진행 상황 섹션 추가**
   - 완료된 작업, 진행 중인 작업, 예정 작업을 체크리스트로 정리
   - 프로젝트 진행 상황을 한눈에 파악 가능

### 개선 효과

1. **가독성 향상**: 문장이 명확해지고 구조화되어 이해하기 쉬워짐
2. **실행 가능성**: 추상적이던 목표가 구체적인 Phase로 나뉘어 실행 가능해짐
3. **문서 완성도**: Terraform 모범사례가 추가되어 개발 가이드로서 완성도 향상
4. **진행 상황 추적**: 작업 진행 상황 섹션으로 프로젝트 관리 용이

### 다음 작업 예정

1. network 루트 모듈 개발 (data source 기반으로 기존 AWS 리소스 참조)
2. ECS 관련 모듈 개발 (ELB, Security Group, Task Definition 등)
3. S3 Backend 설정 구현
4. 모듈 세분화 작업 진행

---

## 2025-11-04: Phase 2 - CMS 프로젝트 ECS 배포 환경 구축 계획

### 루트 모듈 관리 규칙 정립

프로젝트 진행 중 루트 모듈 관리 규칙을 명확히 정의했습니다.

#### 리소스 분류 기준
리소스의 **수명주기(생성·삭제 주체)**와 **재사용 범위**를 기준으로 루트 모듈을 구성합니다.

**1. 공통 인프라 리소스 (`resources/` 디렉토리)**
- 관리 주체: 인프라팀
- 수명주기: 프로젝트와 독립적으로 관리
- 재사용 범위: 여러 프로젝트에서 공통으로 사용
- 예시: Network, 범용 Security Group, 공유 ECR, 공유 EC2
- 위치: `dev/resources/network/`, `dev/resources/elb/`

**2. 프로젝트 전용 리소스 (`projects/{project-name}/` 디렉토리)**
- 관리 주체: 프로젝트 담당자
- 수명주기: 프로젝트와 함께 생성/삭제
- 재사용 범위: 해당 프로젝트 전용
- 예시: 프로젝트 전용 ECR, ECS 클러스터, 프로젝트별 Security Group
- 위치: `dev/projects/cms/` (cms 프로젝트의 모든 전용 리소스 포함)

**3. 향후 멀티 클라우드 대비**
- 현재: `resources/{resource-type}` 구조
- 향후: `resources/aws/{resource-type}`, `resources/gcp/{resource-type}` 형태로 마이그레이션

#### 적용 결정
- **ECR**: CMS 프로젝트 전용이므로 `dev/projects/cms/` 내부에서 리소스로 생성
- **Network, ELB**: 공통 인프라이므로 `dev/resources/` 디렉토리로 이동 필요

### 프로젝트 개요

**프로젝트명**: cms
**애플리케이션 포트**: 3827
**컨테이너 이미지**: Docker 이미지 준비 완료 (ECR 미생성 상태)
**참고 설정**: aws-def 디렉토리의 기존 ECS 설정 기반

### 인프라 구성 요소

#### 1. 기존 리소스 활용 (Data Source로 참조)
- **VPC**: 기존 VPC 사용
- **Subnet**: 기존 Subnet 사용 (서비스 파일 기준: 3개 subnet 사용)
- **ELB (Application Load Balancer)**: 기존 ALB 사용

#### 2. 신규 생성 리소스
- **ECR (Elastic Container Registry)**: cms 프로젝트용 이미지 저장소
- **Security Group**: ECS 서비스 전용 보안 그룹
- **Target Group**: ALB에 연결할 타겟 그룹 (포트 3827)
- **ECS Cluster**: ecs-dev-cms (FARGATE, FARGATE_SPOT)
- **ECS Task Definition**: cms 애플리케이션 정의
- **ECS Service**: cms 서비스 정의

### 필요한 모듈 및 루트 모듈 구조

#### 1. 재사용 가능한 모듈 (`infra/dev/modules/`)
```
infra/dev/modules/
├── common/                     # 공통 네이밍 및 태그 모듈
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
├── ecr/                        # ECR 리포지토리 모듈
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
├── security-group/             # Security Group 모듈
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
├── target-group/               # Target Group 모듈
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
└── ecs/                        # ECS 관련 모듈
    ├── ecs-cluster/            # ECS Cluster 모듈
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── ecs-task-definition/    # ECS Task Definition 모듈
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    └── ecs-service/            # ECS Service 모듈
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

#### 2. 루트 모듈 구조 (규칙 적용 후)
```
infra/dev/
├── resources/                  # 공통 인프라 리소스 (인프라팀 관리)
│   ├── network/                # 네트워크 루트 모듈 (기존 VPC, Subnet 참조)
│   │   ├── terraform.tf
│   │   ├── backend.tf
│   │   ├── main.tf             # data source로 VPC, Subnet 읽기
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   └── elb/                    # ELB 루트 모듈 (기존 ALB 참조)
│       ├── terraform.tf
│       ├── backend.tf
│       ├── main.tf             # data source로 기존 ALB 읽기
│       ├── variables.tf
│       └── outputs.tf
│
└── projects/cms/               # CMS 프로젝트 전용 리소스
    ├── terraform.tf
    ├── backend.tf
    ├── main.tf                 # ECR, Target Group, Security Group, ECS 전체 스택 포함
    ├── variables.tf
    └── outputs.tf
```

### 작업 단계 (규칙 적용 후 수정)

#### Step 1: 공통 인프라 리소스 루트 모듈 작성
1. **dev/resources/network/** - VPC, Subnet data source 작성
2. **dev/resources/elb/** - 기존 ALB data source 작성

#### Step 2: 재사용 가능한 모듈 개발
3. **modules/ecr/** - ECR 리포지토리 생성 모듈
4. **modules/security-group/** - Security Group 생성 모듈
5. **modules/target-group/** - Target Group 생성 모듈 (포트 3827)
6. **modules/ecs-cluster/** - ECS Cluster 생성 모듈
7. **modules/ecs-task-definition/** - Task Definition 생성 모듈
8. **modules/ecs-service/** - ECS Service 생성 모듈

#### Step 3: CMS 프로젝트 전용 리소스 통합
9. **dev/projects/cms/** - CMS 프로젝트의 모든 전용 리소스를 하나의 루트 모듈로 구성
    - ECR 리포지토리 생성 (프로젝트 전용)
    - Target Group 생성 (프로젝트 전용, 포트 3827)
    - Security Group 생성 (프로젝트 전용)
    - ECS Cluster 생성 (프로젝트 전용)
    - Task Definition 생성
    - ECS Service 생성 (Target Group 연결)
    - resources/network, resources/elb State 참조

### ECS 설정 상세 (aws-def 기준)

#### Cluster 설정
- **Capacity Providers**: FARGATE, FARGATE_SPOT
- **Status**: ACTIVE

#### Service 설정
- **Desired Count**: 1
- **Capacity Provider**: FARGATE (weight: 1, base: 0)
- **Platform Version**: LATEST
- **Deployment Configuration**:
  - Circuit Breaker: enabled (rollback: true)
  - Maximum Percent: 200
  - Minimum Healthy Percent: 100
- **Health Check Grace Period**: 90초
- **Scheduling Strategy**: REPLICA
- **Availability Zone Rebalancing**: ENABLED
- **Enable Execute Command**: true
- **Assign Public IP**: ENABLED

#### Network Configuration
- **Subnets**: 3개 subnet 사용 (기존 인프라 참조)
- **Security Groups**: 신규 생성 (포트 3827 허용)
- **Assign Public IP**: ENABLED

#### Load Balancer 연결
- **Target Group**: 신규 생성 (포트 3827)
- **Container Name**: cms
- **Container Port**: 3827

### 예상 산출물

1. **7개의 재사용 가능한 모듈** (common 모듈 추가)
2. **3개의 루트 모듈** (resources/network, resources/elb, projects/cms)
3. **Backend 설정** (S3 + DynamoDB)
4. **완전한 ECS 배포 환경**

---

## 2025-11-04: Phase 2 실제 작업 완료

### 작업 1: 루트 모듈 관리 규칙에 따른 구조 재편성

#### 디렉토리 구조 변경
기존 구조를 규칙에 맞게 재편성했습니다.

**변경 내역:**
```
변경 전:
dev/
├── network/        # 루트 모듈
├── elb/            # 루트 모듈
└── ecr/            # 루트 모듈

변경 후:
dev/
├── resources/      # 공통 인프라 (인프라팀 관리)
│   ├── network/
│   └── elb/
└── projects/       # 프로젝트별 전용 리소스
    └── cms/        # ECR, Target Group, SG, ECS 모두 포함
```

**수행 작업:**
1. `dev/network` → `dev/resources/network` 이동
2. `dev/elb` → `dev/resources/elb` 이동
3. `dev/ecr` 삭제 (cms 프로젝트에 통합)
4. Backend 파일의 State 경로 업데이트
   - `dev/resources/network/backend.tf`: `key = "dev/resources/network/terraform.tfstate"`
   - `dev/resources/elb/backend.tf`: `key = "dev/resources/elb/terraform.tfstate"`

### 작업 2: 재사용 가능한 모듈 개발 (총 7개)

#### 생성된 모듈 목록
1. **modules/common** - 공통 네이밍 및 태그 관리 (신규 추가)
2. **modules/ecr** - ECR 리포지토리
3. **modules/security-group** - Security Group
4. **modules/target-group** - Target Group
5. **modules/ecs-cluster** - ECS Cluster
6. **modules/ecs-task-definition** - ECS Task Definition
7. **modules/ecs-service** - ECS Service

#### modules/common 상세 설명
**목적:** 모든 프로젝트에서 일관된 네이밍과 태그를 사용하기 위한 공통 모듈

**지원하는 네이밍 패턴:**
- 기본: `{environment}-{project_name}` (예: `dev-cms`)
- 서비스 포함: `{environment}-{aws_service}-{project_name}` (예: `dev-ecs-cms`)
- 전체: `{environment}-{aws_service}-{project_name}-{component}` (예: `dev-ecs-cms-api`)

**자동 생성 태그:**
```hcl
{
  Environment = "dev"
  Project     = "cms"
  ManagedBy   = "Terraform"
}
```

**사용 예시:**
```hcl
module "common" {
  source = "../../modules/common"

  environment  = "dev"
  project_name = "cms"
  aws_service  = "ecs"      # 옵션
  component    = "api"       # 옵션
  additional_tags = {}       # 옵션
}

locals {
  name_prefix = module.common.name_prefix
  common_tags = module.common.common_tags
}
```

### 작업 3: dev/projects/cms 통합 루트 모듈 작성

#### 구성 요소
CMS 프로젝트의 모든 전용 리소스를 하나의 루트 모듈에 통합했습니다.

**파일 구조:**
```
dev/projects/cms/
├── terraform.tf       # Terraform >= 1.9.0, AWS Provider ~> 6.18.0
├── backend.tf         # S3 backend (key: dev/projects/cms/terraform.tfstate)
├── variables.tf       # 프로젝트 설정 변수
├── main.tf            # 모든 리소스 정의
└── outputs.tf         # 출력 값
```

**main.tf 구성 섹션:**

1. **Remote State 참조**
   ```hcl
   data "terraform_remote_state" "network" {
     # dev/resources/network State 참조
   }

   data "terraform_remote_state" "elb" {
     # dev/resources/elb State 참조
   }
   ```

2. **공통 모듈 사용**
   ```hcl
   module "common" {
     source       = "../../modules/common"
     environment  = var.environment
     project_name = var.project_name
   }
   ```

3. **ECR Repository** (프로젝트 전용)
   - 리포지토리명: `dev-cms`
   - Lifecycle policy: 7일 이상된 untagged 이미지 삭제, 최근 10개 tagged 이미지 유지

4. **Security Group** (프로젝트 전용)
   - 포트 3827 허용 (ALB에서 들어오는 트래픽)
   - 모든 아웃바운드 트래픽 허용

5. **Target Group** (프로젝트 전용)
   - 포트: 3827
   - 헬스 체크 경로: `/api/ping`
   - Target type: `ip` (Fargate용)

6. **ALB Listener Rule**
   - HTTPS 리스너에 규칙 추가
   - Path 패턴 기반 라우팅: `/cms/*`
   - Priority: 100

7. **ECS Cluster** (프로젝트 전용)
   - Capacity providers: FARGATE, FARGATE_SPOT
   - Container Insights 활성화

8. **CloudWatch Log Group**
   - Log group: `/ecs/dev-cms`
   - 보관 기간: 7일

9. **ECS Task Definition**
   - CPU: 512, Memory: 1024
   - Container 포트: 3827
   - 헬스 체크: `curl -f http://localhost:3827/api/ping`
   - 환경 변수: PORT, ENVIRONMENT

10. **ECS Service**
    - Desired count: 1
    - Capacity provider: FARGATE (weight: 1)
    - Deployment circuit breaker 활성화
    - ECS Exec 활성화
    - Health check grace period: 90초

**주요 변수 (variables.tf):**
```hcl
variable "container_port" {
  default = 3827
}

variable "task_cpu" {
  default = "512"
}

variable "task_memory" {
  default = "1024"
}

variable "health_check_path" {
  default = "/api/ping"
}

variable "task_role_arn" {
  default = "arn:aws:iam::365485194891:role/ecsTaskRole"
}

variable "execution_role_arn" {
  default = "arn:aws:iam::365485194891:role/ecsTaskExecutionRole"
}
```

### 작업 결과 요약

#### 완성된 디렉토리 구조
```
infra/dev/
├── modules/
│   ├── common/                 # 공통 네이밍 및 태그 (신규)
│   ├── ecr/
│   ├── security-group/
│   ├── target-group/
│   └── ecs/                    # ECS 관련 모듈 (구조화)
│       ├── ecs-cluster/
│       ├── ecs-task-definition/
│       └── ecs-service/
│
├── resources/                  # 공통 인프라 (인프라팀 관리)
│   ├── network/
│   │   ├── terraform.tf
│   │   ├── backend.tf         # State: dev/resources/network/terraform.tfstate
│   │   ├── main.tf            # data source로 VPC, Subnet 참조
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   └── elb/
│       ├── terraform.tf
│       ├── backend.tf         # State: dev/resources/elb/terraform.tfstate
│       ├── main.tf            # data source로 ALB 참조
│       ├── variables.tf
│       └── outputs.tf
│
└── projects/                  # 프로젝트별 전용 리소스
    └── cms/
        ├── terraform.tf
        ├── backend.tf         # State: dev/projects/cms/terraform.tfstate
        ├── main.tf            # ECR, SG, TG, ECS 전체 스택
        ├── variables.tf
        └── outputs.tf
```

#### 핵심 설계 원칙 적용
1. ✅ **수명주기 관리**: 공통 인프라는 resources/, 프로젝트 전용은 projects/
2. ✅ **재사용성**: 7개의 모듈로 코드 재사용
3. ✅ **일관성**: common 모듈로 네이밍과 태그 통일
4. ✅ **격리성**: State 파일을 리소스 타입별로 분리
5. ✅ **참조 관리**: Remote State로 공통 인프라 참조

### 다음 세션 작업 가이드

#### 1. 초기 설정 (첫 배포 시)
```bash
# 1. resources/network 배포
cd dev/resources/network
terraform init
terraform plan
terraform apply

# 2. resources/elb 배포
cd ../elb
terraform init
terraform plan
terraform apply

# 3. projects/cms 배포
cd ../../projects/cms
terraform init
terraform plan
terraform apply
```

#### 2. 새로운 프로젝트 추가 시
```bash
# dev/projects/{new-project}/ 디렉토리 생성
# main.tf 작성 시:
# - module "common" 사용
# - data "terraform_remote_state" "network" 참조
# - data "terraform_remote_state" "elb" 참조
# - 프로젝트 전용 리소스 정의
```

#### 3. 공통 모듈 사용 패턴
```hcl
module "common" {
  source       = "../../modules/common"
  environment  = var.environment
  project_name = var.project_name
}

locals {
  name_prefix = module.common.name_prefix
  common_tags = module.common.common_tags
}

# 리소스 생성 시
module "ecr" {
  source          = "../../modules/ecr"
  repository_name = local.name_prefix
  tags            = local.common_tags
}
```

#### 4. Terraform 버전 통일
모든 루트 모듈과 모듈에서 동일한 버전 사용:
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

### 주의사항

1. **루트 모듈 생성 시 반드시 규칙 준수**
   - 공통 인프라 → `dev/resources/{resource-type}/`
   - 프로젝트 전용 → `dev/projects/{project-name}/`

2. **Backend State Key 규칙**
   - Resources: `dev/resources/{resource-type}/terraform.tfstate`
   - Projects: `dev/projects/{project-name}/terraform.tfstate`

3. **네이밍 규칙 일관성**
   - 항상 `module "common"` 사용
   - `{environment}-{project_name}` 형식 준수

4. **태그 일관성**
   - 모든 리소스에 `common_tags` 적용
   - 추가 태그는 `additional_tags`로 병합

5. **Remote State 참조**
   - 공통 인프라는 항상 resources State 참조
   - State bucket, key, region 정확히 지정

---

## 2025-11-04: 모듈 테스트 프레임워크 구축

### 테스트 환경 구성

프로젝트의 모듈 품질 보증을 위해 `tests/` 디렉토리에 테스트 프레임워크를 구축했습니다.

#### 테스트 디렉토리 구조
```
tests/
└── ecs-service-test/           # ECS Service 모듈 테스트
    ├── .terraform/             # Terraform 초기화 파일
    ├── .terraform.lock.hcl     # Provider 버전 잠금 파일
    └── main.tf                 # 테스트 설정 파일
```

### 테스트 방법론

#### 1. 테스트 파일 구성
각 모듈별 테스트 디렉토리를 생성하고 `main.tf`에 테스트 케이스를 작성합니다.

**테스트 파일 구조:**
```hcl
# tests/{module-name}-test/main.tf

# 1. Terraform 및 Provider 설정
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.18.0"
    }
  }
}

provider "aws" {
  region = "ap-northeast-2"
}

# 2. 모듈 테스트 케이스
module "test_module" {
  source = "../../infra/dev/modules/{module-path}"

  # 테스트용 변수 설정
  # ARN, ID 등은 더미 값 사용 가능
}
```

#### 2. 테스트 실행 절차

```bash
# 1. 테스트 디렉토리 이동
cd tests/{module-name}-test

# 2. Terraform 초기화 (모듈 다운로드 및 Provider 설치)
terraform init

# 3. 구문 검증 (HCL 문법 및 설정 유효성 검사)
terraform validate

# 4. 실행 계획 확인 (리소스 생성 없이 dry-run)
terraform plan
```

#### 3. 테스트 성공 기준

**✅ 테스트 통과 조건:**
1. `terraform validate` → "Success! The configuration is valid."
2. `terraform plan` → 오류 없이 실행 계획 생성
3. 예상한 리소스가 계획에 포함됨

**❌ 테스트 실패 사례:**
- 구문 오류 (Unsupported argument, Unsupported block type)
- 필수 변수 누락
- 타입 불일치
- 모듈 경로 오류

### ECS Service 모듈 테스트 사례

#### 테스트 수행 과정

**1. 초기 테스트 실패**
```bash
cd tests/ecs-service-test
terraform validate

# Error: Unsupported argument
# on ../../infra/dev/modules/ecs/ecs-service/main.tf line 39
# An argument named "maximum_percent" is not expected here.
```

**문제점:** `deployment_configuration` 블록 구조가 AWS Provider의 ECS Service 리소스 스키마와 불일치

**2. 모듈 수정**
[infra/dev/modules/ecs/ecs-service/main.tf:38](infra/dev/modules/ecs/ecs-service/main.tf#L38)

변경 전:
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

변경 후:
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

**3. 테스트 성공**
```bash
terraform validate
# ✅ Success! The configuration is valid.

terraform plan
# ✅ Plan: 1 to add, 0 to change, 0 to destroy.
```

**생성 예정 리소스 확인:**
```
# module.aws_ecs_service.aws_ecs_service.this will be created
+ resource "aws_ecs_service" "this" {
    + cluster                            = "arn:aws:ecs:ap-northeast-2:123456789012:cluster/test"
    + deployment_maximum_percent         = 200
    + deployment_minimum_healthy_percent = 100
    + desired_count                      = 1
    + enable_execute_command             = true
    + launch_type                        = "FARGATE"
    + platform_version                   = "LATEST"

    + deployment_circuit_breaker {
        + enable   = true
        + rollback = true
    }

    + network_configuration {
        + assign_public_ip = true
        + security_groups  = ["sg-xxx"]
        + subnets          = ["subnet-xxx"]
    }
}
```

### 테스트 결과 요약

#### 테스트 완료 모듈
1. ✅ **ECS Service 모듈** ([tests/ecs-service-test](tests/ecs-service-test/main.tf))
   - 모듈 경로: `infra/dev/modules/ecs/ecs-service`
   - 테스트 상태: 통과
   - 검증 항목:
     - ECS Service 리소스 생성
     - Deployment configuration 설정
     - Circuit breaker 설정
     - Network configuration 설정
     - Launch type FARGATE 설정

#### 테스트 대기 모듈
- [ ] ECS Cluster 모듈
- [ ] ECS Task Definition 모듈
- [ ] ECR 모듈
- [ ] Security Group 모듈
- [ ] Target Group 모듈
- [ ] Common 모듈

### 테스트 모범 사례

#### 1. 모듈 경로 설정
```hcl
# ✅ 올바른 경로 (infra/ 하위)
source = "../../infra/dev/modules/ecs/ecs-service"

# ❌ 잘못된 경로
source = "../../dev/modules/ecs-service"  # infra/ 누락
```

#### 2. 더미 값 사용
테스트 시 실제 AWS 리소스 ARN이 필요하지 않은 경우 더미 값 사용:
```hcl
cluster_id          = "arn:aws:ecs:ap-northeast-2:123456789012:cluster/test"
task_definition_arn = "arn:aws:ecs:ap-northeast-2:123456789012:task-definition/test:1"
subnets             = ["subnet-xxx"]
security_groups     = ["sg-xxx"]
```

#### 3. 필수 변수만 설정
테스트 시 선택적 변수는 모듈의 기본값 사용:
```hcl
module "test" {
  source = "..."

  # 필수 변수만 설정
  name                = "test-svc"
  cluster_id          = "..."
  task_definition_arn = "..."

  # 선택적 변수는 기본값 사용 (명시 불필요)
}
```

#### 4. 반복 테스트
모듈 수정 후 즉시 테스트 실행하여 회귀 방지:
```bash
# 모듈 수정 후
cd tests/{module-name}-test
terraform init      # 모듈 업데이트
terraform validate  # 구문 검증
terraform plan      # 동작 검증
```

### 향후 테스트 확장 계획

#### 1. 통합 테스트
여러 모듈을 조합한 통합 테스트 작성:
```
tests/
└── integration-test/
    └── ecs-full-stack-test/  # Cluster + Task Definition + Service
```

#### 2. 자동화 테스트
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

#### 3. 실제 배포 테스트
개발 환경에 실제 리소스 배포 후 동작 확인:
```bash
# 주의: 실제 AWS 리소스 생성 (비용 발생)
terraform apply -auto-approve
# 테스트 후 정리
terraform destroy -auto-approve
```

### 테스트 문서화

모든 테스트 결과는 다음 정보를 포함해야 합니다:
1. **테스트 일시**: 2025-11-04
2. **테스트 모듈**: ECS Service
3. **테스트 결과**: 통과/실패
4. **발견된 이슈**: deployment_configuration 구조 오류
5. **수정 내용**: deployment_* 속성을 리소스 최상위로 이동
6. **검증 방법**: terraform validate, terraform plan
