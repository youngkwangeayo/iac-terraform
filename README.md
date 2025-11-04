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
│   │   ├── network/            # 네트워크 모듈 (VPC, Subnet, Security Group)
│   │   │   ├── main.tf
│   │   │   ├── variables.tf
│   │   │   └── outputs.tf
│   │   ├── ec2/                # EC2 모듈
│   │   │   ├── main.tf
│   │   │   ├── variables.tf
│   │   │   └── outputs.tf
│   │   └── ecs/                # ECS 모듈
│   │       ├── main.tf
│   │       ├── variables.tf
│   │       └── outputs.tf
│   │
│   ├── network/                # 네트워크 루트 모듈
│   │   ├── terraform.tf        # Terraform 버전 및 Provider 설정
│   │   ├── backend.tf          # S3 backend 설정
│   │   ├── main.tf             # data source로 기존 VPC 등을 읽어 State 관리
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   ├── computing/              # 컴퓨팅 루트 모듈
│   │   ├── terraform.tf        # Terraform 버전 및 Provider 설정
│   │   ├── backend.tf          # S3 backend 설정
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   └── projects/               # 실제 프로젝트 배포 루트 모듈
│       └── project-example/
│           ├── terraform.tf    # Terraform 버전 및 Provider 설정
│           ├── backend.tf      # S3 backend 설정
│           ├── main.tf         # network, computing State 참조
│           ├── variables.tf
│           └── outputs.tf
│
└── prod/                       # 운영 환경 (dev와 동일한 구조)
    ├── modules/
    ├── network/
    ├── computing/
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