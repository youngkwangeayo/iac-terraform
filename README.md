# IaC 템플릿화 프로젝트

## 전체 목표
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


## 네이밍 규칙
**형식**: `{aws-service}-{environment}-{solution}[-{component}]`

### 예시
- `ecs-dev-myapp`
- `service-dev-mys1-api`
- `ecs-prod-payment-web`
- `rds-dev-myapp`

## 루트 모듈 관리 규칙

### 리소스 분류 기준
리소스의 **수명주기(생성·삭제 주체)**와 **재사용 범위**를 기준으로 루트 모듈을 구성합니다.

#### 1. 공통 인프라 리소스 (`resources/` 디렉토리)
- **관리 주체**: 인프라팀
- **수명주기**: 프로젝트와 독립적으로 관리
- **재사용 범위**: 여러 프로젝트에서 공통으로 사용
- **예시**: Network, 범용 Security Group, 공유 ECR, 공유 EC2 등
- **위치**: `dev/resources/network/`, `dev/resources/elb/`

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
# 현재 구조
dev/
├── resources/              # 공통 인프라 리소스 (인프라팀 관리)
│   ├── network/           # 공통 네트워크 (VPC, Subnet 참조)
│   └── elb/               # 공통 로드밸런서 참조
│
└── projects/              # 프로젝트별 전용 리소스
    └── cms/               # CMS 프로젝트
        ├── ecr/           # CMS 전용 ECR (프로젝트와 생명주기 동일)
        ├── cluster/       # CMS 전용 ECS Cluster
        └── service/       # CMS ECS Service

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
├── dev/                        # 개발 환경
│   ├── modules/                # 재사용 가능한 Terraform 모듈
│   │   ├── ecr/                # ECR 모듈
│   │   ├── security-group/     # Security Group 모듈
│   │   ├── target-group/       # Target Group 모듈
│   │   ├── ecs-cluster/        # ECS Cluster 모듈
│   │   ├── ecs-task-definition/# ECS Task Definition 모듈
│   │   └── ecs-service/        # ECS Service 모듈
│   │
│   ├── resources/              # 공통 인프라 리소스 (인프라팀 관리)
│   │   ├── network/            # 네트워크 루트 모듈
│   │   │   ├── terraform.tf    # Terraform 버전 및 Provider 설정
│   │   │   ├── backend.tf      # S3 backend 설정
│   │   │   ├── main.tf         # data source로 기존 VPC 등을 읽어 State 관리
│   │   │   ├── variables.tf
│   │   │   └── outputs.tf
│   │   │
│   │   └── elb/                # ELB 루트 모듈
│   │       ├── terraform.tf
│   │       ├── backend.tf
│   │       ├── main.tf         # 기존 ALB 참조 및 Target Group 생성
│   │       ├── variables.tf
│   │       └── outputs.tf
│   │
│   └── projects/               # 프로젝트별 전용 리소스
│       └── cms/                # CMS 프로젝트
│           ├── terraform.tf    # Terraform 버전 및 Provider 설정
│           ├── backend.tf      # S3 backend 설정
│           ├── main.tf         # ECR, ECS Cluster, Service 등 모든 리소스 포함
│           ├── variables.tf
│           └── outputs.tf
│
└── prod/                       # 운영 환경 (dev와 동일한 구조)
    ├── modules/
    ├── resources/
    └── projects/
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

## 작업 진행 상황

### 완료
- [x] 프로젝트 디렉토리 구조 설계
- [x] dev/prod 환경별 디렉토리 생성

### 진행 중
- [ ] network 루트 모듈 개발 (data source 기반)
- [ ] ECS 관련 모듈 개발

### 예정
- [ ] S3 Backend 설정
- [ ] 모듈 세분화 (VPC, Subnet, Security Group 등)
- [ ] 프로젝트별 배포 템플릿 작성