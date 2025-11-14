# IaC 템플릿화 프로젝트

## 📋 목차
1. [프로젝트 개요](#프로젝트-개요)
2. [현재 상태](#현재-상태) ⭐
3. [디렉토리 구조](#디렉토리-구조)
4. [개발 규칙](#개발-규칙)
5. [모듈 테스트](#모듈-테스트)
6. [작업 진행 상황](#작업-진행-상황)

## 프로젝트 개요

Terraform을 활용한 IaC 템플릿 구성으로 모듈 기반 개발을 하며, 개발 표준 및 모범 사례를 준수합니다.
AWS 인프라를 재사용 가능한 IaC 템플릿으로 구성하여 다양한 솔루션을 빠르게 배포할 수 있도록 합니다.

### 기존 리소스 마이그레이션 전략
- Terraform으로 관리되지 않는 기존 AWS 리소스는 data source를 사용하여 참조합니다
- 루트 모듈에서 data source로 기존 리소스를 읽어 State에 저장합니다
- 다른 프로젝트에서는 해당 State를 참조하여 사용합니다
- 예시: network 루트 모듈에서 data source로 VPC를 읽고, 프로젝트에서 network State를 참조

### 단계별 목표

#### Phase 1: 네트워크 인프라 모듈화
- network 루트 모듈에서 data source로 기존 AWS 리소스를 읽어 관리
- 프로젝트에서 network State를 참조하는 구조 구현

#### Phase 2: ECS 배포 환경 구축
- ECS 관련 모듈 개발 (ELB, Security Group, Task Definition 등)
- 완전한 ECS 배포 환경 구축 및 테스트

## 현재 상태

### ✅ 완료된 작업

#### 1. 프로젝트 구조 설계 및 구축
- [x] 디렉토리 구조 설계 (`infra/modules/`, `infra/dev/`, `infra/prod/`)
- [x] 환경 독립적인 모듈 구조로 개선 (`infra/modules/`)
- [x] 루트 모듈 관리 규칙 정립 (`resources/`, `projects/`)

#### 2. 재사용 가능한 모듈 개발 (7개)
- [x] **common** - 공통 네이밍 및 태그 관리
- [x] **ecr** - ECR Repository
- [x] **security-group** - Security Group
- [x] **target-group** - Target Group
- [x] **ecs-cluster** - ECS Cluster
- [x] **ecs-task-definition** - ECS Task Definition
- [x] **ecs-service** - ECS Service

#### 3. 모듈 테스트 완료
- [x] 7개 모듈 모두 테스트 통과 (`terraform validate`, `terraform plan`)
- [x] 테스트 결과 문서화 ([tests/TEST-RESULT.md](tests/TEST-RESULT.md))
- [x] 테스트 프레임워크 구축 (`tests/` 디렉토리)

#### 4. 루트 모듈 작성 완료
- [x] `infra/dev/resources/network` - VPC, Subnet data source
- [x] `infra/dev/resources/elb` - ALB data source
- [x] `infra/dev/projects/cms` - CMS 프로젝트 전체 스택

#### 5. Terraform Backend 구축 및 연동
- [x] S3 Bucket (`nextpay-terraform-state`) 생성
- [x] DynamoDB Table (`nextpay-terraform-locks`) 생성
- [x] 3개 루트 모듈 backend.tf 설정 완료
- [x] terraform init 성공 확인

#### 6. Network 디렉토리 구조 개선 및 State 생성
- [x] VPC별 State 격리 구조 적용 (`dev/resources/network/nextpay/`)
- [x] VPC 매핑 전략 수립 (환경별 디렉토리 관리)
- [x] dev-vpc (vpc-276cc74c) State 생성 완료
- [x] Private/Public Subnet 필터링 개선 (소문자 매칭)
- [x] S3 Backend State 마이그레이션 완료
- [x] 이전 경로 State 파일 정리 완료

#### 7. ELB 디렉토리 구조 적용 및 State 생성
- [x] ELB 디렉토리 구조 적용 (`dev/resources/elb/nextpay/`)
- [x] dev-cms-elb State 생성 완료
- [x] Network State 참조 추가
- [x] CMS 모듈 ELB 참조 경로 업데이트
- [x] S3 Backend에 State 저장 완료

#### 8. IAM Role Terraform 관리 전환
- [x] 기존 IAM Role (ecsTaskExecutionRole, ecsTaskRole) 정책 확인
- [x] IAM 루트 모듈 생성 (`dev/resources/iam/ecs-roles/`)
- [x] 8개 Policy Attachment 포함 (ExecutionRole 4개, TaskRole 4개)
- [x] Terraform import 완료 (Role 2개 + Policy Attachment 8개)
- [x] terraform apply 완료 (태그만 추가, 정책 유지)
- [x] S3 Backend State 저장 (`dev/resources/iam/ecs-roles/terraform.tfstate`)

#### 9. CMS 프로젝트 1차 배포 완료
- [x] Route53 레코드 모듈 개발 (`infra/modules/route53-record/`)
- [x] CMS DNS 레코드 생성 (`dev-cms.nextpay.co.kr`)
- [x] Security Group 모듈 개선 (Protocol -1 포트 처리)
- [x] Network 모듈: Pvt 서브넷 제외, NAT Gateway 있는 Private 서브넷만 사용
- [x] CMS 헬스체크 경로: `/command/checkHealth`
- [x] ECS Service 배포 완료 (Task Running)
- [x] Task Definition Revision 4

#### 10. ECS 이미지 버전 관리 분리
- [x] ECS Task Definition에 `lifecycle { ignore_changes = [container_definitions] }` 추가
- [x] ECS Service에 `lifecycle { ignore_changes = [desired_count, task_definition] }` 추가
- [x] Terraform이 앱팀의 이미지 버전 업데이트를 무시하도록 설정
- [x] 앱 개발자가 CI/CD로 자유롭게 이미지 태그 관리 가능

### 🔄 다음 작업 (우선순위 순)

#### 1. Variables 리팩토링 (tfvars 기반 운영)
- [ ] 모듈 variables.tf의 불필요한 default 값 제거
- [ ] 프로젝트/리소스 variables.tf의 불필요한 default 값 제거
- [ ] terraform.tfvars 파일 생성 및 적용
- [ ] 재사용 편의성 개선

#### 2. 민감정보 관리 개선
- [ ] AWS Secrets Manager 또는 SSM Parameter Store 적용
- [ ] Task Definition secrets 필드 활용
- [ ] 환경변수 외부화

### 📊 진행률

**Phase 2 (ECS 배포 환경 구축): 100% 완료** ✅

- ✅ 모듈 개발 (100%)
  - Route53 Record 모듈 추가
  - Security Group 모듈 개선
- ✅ 모듈 테스트 (100%)
- ✅ 루트 모듈 작성 (100%)
- ✅ 인프라 배포 (100%)
  - ✅ Backend 설정 (S3 + DynamoDB)
  - ✅ Backend 연동 확인 (terraform init)
  - ✅ Network State 생성 (dev-vpc, NAT Gateway 있는 서브넷만)
  - ✅ ELB State 생성 (dev-cms-elb)
  - ✅ IAM Role Terraform 관리 전환
  - ✅ CMS 프로젝트 1차 배포 완료


## 네이밍 규칙
**형식**: `{aws-service}-{environment}-{solution}[-{component}]`

### 예시
- `ecs-dev-myapp`
- `service-dev-mys1-api`
- `ecs-prod-payment-web`
- `rds-dev-myapp`

## 루트 모듈 관리 규칙

### VPC 관리 전략

#### VPC별 State 격리
각 VPC는 독립적인 루트 모듈로 관리하며, **환경별 디렉토리**에 위치시킵니다.

**현재 AWS VPC 현황** (콘솔로 생성된 기존 리소스):
- `dev-vpc`: nextpay 개발 환경
- `nextpay1-vpc`: nextpay 운영 환경
- `prod-ai-platform-vpc`: AI Platform 운영 환경

**Terraform 디렉토리 매핑**:
| Terraform 경로 | AWS VPC 이름 | 환경 | 설명 |
|----------------|--------------|------|------|
| `dev/resources/network/nextpay/` | `dev-vpc` | Dev | nextpay 개발 |
| `prod/resources/network/nextpay/` | `nextpay1-vpc` | Prod | nextpay 운영 |
| `prod/resources/network/ai-platform/` | `prod-ai-platform-vpc` | Prod | AI Platform 운영 |

**왜 VPC별로 분리?**
- State 격리: 각 VPC가 독립적인 State 파일 보유
- 안전성: 한 VPC 작업이 다른 VPC에 영향 없음
- 확장성: 새로운 VPC 추가 시 동일 패턴 적용

### 리소스 분류 기준
리소스의 **수명주기(생성·삭제 주체)**와 **재사용 범위**를 기준으로 루트 모듈을 구성합니다.

#### 1. 공통 인프라 리소스 (`resources/` 디렉토리)
- **관리 주체**: 인프라팀
- **수명주기**: 프로젝트와 독립적으로 관리
- **재사용 범위**: 여러 프로젝트에서 공통으로 사용
- **예시**: Network (VPC별), ELB, 공유 Security Group
- **위치**: `dev/resources/network/nextpay/`, `dev/resources/elb/`

#### 2. 프로젝트 전용 리소스 (`projects/{project-name}/` 디렉토리)
- **관리 주체**: 프로젝트 담당자
- **수명주기**: 프로젝트와 함께 생성/삭제
- **재사용 범위**: 해당 프로젝트 전용
- **예시**: 프로젝트 전용 ECR, ECS 클러스터, 프로젝트별 Security Group
- **위치**: `dev/projects/cms/` (cms 프로젝트 전용 리소스 포함)

#### 3. 향후 멀티 클라우드 대비
현재는 `resources/{resource-type}` 구조를 사용하며, 향후 다른 클라우드 벤더 추가 시 `resources/aws/{resource-type}` 형태로 마이그레이션 예정

### 적용 예시

```
# 현재 구조 (환경별 VPC 관리)
dev/
├── resources/
│   ├── network/
│   │   └── nextpay/       # dev-vpc 관리 (nextpay 개발 환경)
│   └── elb/
└── projects/
    └── cms/

prod/
├── resources/
│   ├── network/
│   │   ├── nextpay/       # nextpay1-vpc 관리 (nextpay 운영 환경)
│   │   └── ai-platform/   # prod-ai-platform-vpc 관리 (AI Platform 운영 환경)
│   └── elb/
└── projects/

# 향후 멀티 클라우드 구조 (마이그레이션)
dev/
├── resources/
│   ├── aws/               # AWS 리소스
│   │   ├── network/
│   │   └── elb/
│   └── gcp/               # GCP 리소스
│       └── network/
```

## 디렉토리 구조

```
tf-aws-module/
├── aws-def/                    # AWS describe 명령으로 생성된 참고 파일 (ECS 구성 시 참고용)
│   ├── cluster-dev.json        # ECS 클러스터 정의
│   ├── taskdef-dev.json        # Task Definition
│   ├── service-dev.json        # ECS 서비스 정의
│   └── autoscal-dev.json       # Auto Scaling 설정
│
├── infra/                      # 인프라 코드 루트
│   ├── modules/                # 재사용 가능한 Terraform 모듈 (환경 독립적)
│   │   ├── common/             # 공통 네이밍 및 태그 모듈
│   │   ├── ecr/                # ECR 모듈
│   │   ├── security-group/     # Security Group 모듈
│   │   ├── target-group/       # Target Group 모듈
│   │   └── ecs/                # ECS 관련 모듈
│   │       ├── ecs-cluster/            # ECS Cluster 모듈
│   │       ├── ecs-task-definition/    # ECS Task Definition 모듈
│   │       └── ecs-service/            # ECS Service 모듈
│   │
│   ├── dev/                    # 개발 환경
│   │   ├── resources/          # 공통 인프라 리소스 (인프라팀 관리)
│   │   │   ├── network/        # 네트워크 리소스 (VPC별 관리)
│   │   │   │   ├── dev-vpc/        # dev-vpc 전용
│   │   │   │   │   ├── terraform.tf
│   │   │   │   │   ├── backend.tf      # key: dev/resources/network/dev-vpc/terraform.tfstate
│   │   │   │   │   ├── main.tf         # data source로 dev-vpc 읽어 State 관리
│   │   │   │   │   ├── variables.tf
│   │   │   │   │   └── outputs.tf
│   │   │   │   ├── dev-vpc/   # dev-vpc 전용 (예정)
│   │   │   │   └── prod-ai-platform-vpc/  # prod-ai-platform-vpc 전용 (예정)
│   │   │   │
│   │   │   └── elb/            # ELB 루트 모듈
│   │   │       ├── terraform.tf
│   │   │       ├── backend.tf
│   │   │       ├── main.tf     # 기존 ALB 참조 및 Target Group 생성
│   │   │       ├── variables.tf
│   │   │       └── outputs.tf
│   │   │
│   │   └── projects/           # 프로젝트별 전용 리소스
│   │       └── cms/            # CMS 프로젝트
│   │           ├── terraform.tf    # Terraform 버전 및 Provider 설정
│   │           ├── backend.tf      # S3 backend 설정
│   │           ├── main.tf         # ECR, ECS Cluster, Service 등 모든 리소스 포함
│   │           ├── variables.tf
│   │           └── outputs.tf
│   │
│   └── prod/                   # 운영 환경 (dev와 동일한 구조)
│       ├── resources/
│       └── projects/
│
└── tests/                      # 모듈 테스트 디렉토리
    ├── ecs-service-test/       # ECS Service 모듈 테스트
    │   └── main.tf
    └── ecr-test/               # ECR 모듈 테스트
        └── main.tf
```

## Terraform 모범사례

### 모듈 개발 원칙
- **모듈 네이밍 규칙**: `terraform-<PROVIDER>-<NAME>` (예: `terraform-aws-vpc`)
- **모듈 우선 설계**: 처음부터 재사용 가능한 모듈 구조로 작성
- **단일 책임 원칙**: 각 모듈은 하나의 명확한 목적을 가져야 함
- **입출력 명확화**: variables.tf와 outputs.tf로 인터페이스를 명확히 정의

### State 관리
- **Backend**: S3 + DynamoDB를 사용한 State 잠금 및 버전 관리
- **State 격리**: 환경(dev/prod)과 루트 모듈별로 State 분리
- **State 참조**: `terraform_remote_state` data source로 다른 모듈의 State 참조

### 환경 관리
- **환경 분리**: dev, prod 디렉토리로 환경 완전 분리
- **공통 코드**: 모듈을 통해 공통 로직 재사용
- **환경별 설정**: variables.tf와 terraform.tfvars로 환경별 차이 관리

## 모듈 테스트

### 테스트 진행 방법

모듈 개발 완료 후 `tests/` 디렉토리에서 단위 테스트를 수행합니다.

#### 1. 테스트 파일 작성
```hcl
# tests/{module-name}-test/main.tf
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

module "test_module" {
  source = "../../infra/modules/{module-path}"
  # 테스트용 변수 설정
}
```

#### 2. 테스트 실행
```bash
cd tests/{module-name}-test

# 모듈 초기화
terraform init

# 구문 검증
terraform validate

# 실행 계획 확인 (실제 리소스 생성 없이 검증)
terraform plan
```

#### 3. 테스트 예시: ECS Service 모듈
```bash
cd tests/ecs-service-test
terraform init
terraform validate  # ✅ Success! The configuration is valid.
terraform plan      # Plan: 1 to add, 0 to change, 0 to destroy.
```

#### 4. 테스트 결과 문서화

**중요**: 모든 테스트 결과는 반드시 `tests/TEST-RESULT.md` 파일에 기록해야 합니다.

각 테스트 결과는 다음 정보를 포함해야 합니다:
- 테스트 일시
- 테스트 모듈명
- 테스트 결과 (통과/실패)
- 발견된 이슈 (있을 경우)
- 수정 내용 (있을 경우)
- 검증 방법

자세한 내용은 [tests/TEST-RESULT.md](tests/TEST-RESULT.md)를 참고하세요.

### 테스트 완료 모듈
- [x] ECS Service 모듈 - [tests/ecs-service-test](tests/ecs-service-test/main.tf)
- [x] ECR 모듈 - [tests/ecr-test](tests/ecr-test/main.tf)

## 작업 진행 상황

### 완료
- [x] 프로젝트 디렉토리 구조 설계 (infra/ 하위로 재구성)
- [x] dev/prod 환경별 디렉토리 생성
- [x] ECS 관련 모듈 개발 (ecs/ 디렉토리 내 구조화)
- [x] common 모듈 개발 (네이밍 및 태그 표준화)
- [x] 모듈 테스트 프레임워크 구축

### 진행 중
- [ ] network 루트 모듈 개발 (data source 기반)
- [ ] 추가 모듈 테스트 작성

### 예정
- [ ] S3 Backend 설정
- [ ] 모듈 세분화 (VPC, Subnet, Security Group 등)
- [ ] 프로젝트별 배포 템플릿 작성