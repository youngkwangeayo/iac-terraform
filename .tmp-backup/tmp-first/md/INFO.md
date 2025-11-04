# tf-aws-module 프로젝트 분석

## 프로젝트 개요
재사용 가능한 모듈 아키텍처로 구성된 Terraform IaC 템플릿 기반 AWS 인프라 관리 시스템

## 핵심 목표
- 재사용 가능한 Terraform 모듈 개발
- 개발 표준 및 모범 사례 준수
- 빠른 솔루션 배포 지원
- AWS ECS 배포 실습

## 디렉토리 구조

```
tf-aws-module/
├── terraform.tf              # Terraform 버전 및 프로바이더 요구사항
├── providers.tf              # AWS 프로바이더 설정 및 공통 태그
├── variables.tf              # 전역 변수 (region, aws_profile, project, env)
│
├── modules/                  # 재사용 가능한 Terraform 모듈
│   └── ec2/                 # EC2 인스턴스 모듈
│       ├── main.tf          # EC2 리소스 정의
│       ├── variables.tf     # 모듈 입력 변수
│       └── outputs.tf       # 모듈 출력값
│
├── solutions/               # 특정 솔루션/프로젝트 구성
│   └── tmp-app/            # 임시 애플리케이션 솔루션
│       ├── main.tf
│       └── variables.tf
│
├── tmp-modern/              # 테라폼 테스트
│   ├── main.tf              # S3 버킷 생성 데모
│   ├── versions.tf          # Terraform 버전 설정
│   ├── providers.tf         # 프로바이더 설정
│   └── variables.tf         # 변수 정의
│
├── envs/                    # 환경별 배포 설정 (비어있음)
│   ├── prod/
│   ├── stage/
│   └── dev/
│
├── aws-def/                 # AWS 리소스 참조 파일
│   ├── cluster-dev.json     # ECS 클러스터 정의
│   ├── taskdef-dev.json     # ECS 태스크 정의
│   ├── service-dev.json     # ECS 서비스 정의
│   ├── autoscal-dev.json    # Auto Scaling 설정
│   └── scaling-policies-dev.yaml  # 스케일링 정책
│
└── md/                      # 문서
    ├── INFO.md              # 프로젝트 분석 문서
    └── run.sh.md            # 실행 스크립트 가이드
```

## 주요 파일 상세

### 1. 루트 레벨 설정

#### terraform.tf
- 최소 Terraform 버전: >= 1.9.0
- AWS 프로바이더 버전: ~> 5.57

#### providers.tf
- AWS 프로바이더 설정
- region 및 profile 변수 사용
- 기본 태그: Project, Env, Owner, Managed

#### variables.tf
전역 변수:
- `region`: AWS 리전
- `aws_profile`: AWS CLI 프로파일명
- `project`: 프로젝트명 (기본값: "nextpay")
- `env`: 환경명 (기본값: "prod")

### 2. modules/ec2/ - EC2 모듈

#### 입력 변수 (variables.tf)
- `ami_id`: AMI ID
- `instance_type`: 인스턴스 타입 (예: t3.micro)
- `subnet_id`: 서브넷 ID
- `security_group_ids`: 보안 그룹 ID 리스트
- `key_name`: SSH 키 페어명
- `associate_public_ip`: 퍼블릭 IP 할당 여부
- `user_data`: 초기화 스크립트
- `instance_name`: 인스턴스 논리명
- `project`, `env`: 태깅용
- `extra_tags`: 추가 커스텀 태그

#### 출력값 (outputs.tf)
- `instance_id`: EC2 인스턴스 ID
- `public_ip`: 퍼블릭 IP 주소
- `private_ip`: 프라이빗 IP 주소

#### 리소스 (main.tf)
- `aws_instance.this`: EC2 인스턴스 생성
- 자동 네이밍: `{project}-{env}-{instance_name}`

### 3. tmp-modern/ - 데모 환경

#### main.tf
- AWS 계정 정보 조회 (`aws_caller_identity`)
- AWS 리전 정보 조회 (`aws_region`)
- S3 버킷 생성 데모
  - 버킷명: `{project}-{env}-terraform-demo-bucket`
  - force_destroy: true

### 4. aws-def/ - AWS 참조 설정

ECS 관련 실제 AWS 리소스 정의 파일:
- `cluster-dev.json`: ECS 클러스터
- `taskdef-dev.json`: ECS 태스크 정의
- `service-dev.json`: ECS 서비스
- `autoscal-dev.json`: Auto Scaling 설정
- `scaling-policies-dev.yaml`: 스케일링 정책

## 네이밍 규칙

**형식**: `{aws-service}-{environment}-{solution}[-{component}]`

**예시**:
- `ecs-dev-myapp`
- `ecs-dev-mys1-api`
- `ecs-prod-payment-web`
- `rds-dev-myapp`

## 현재 구현 상태

### 완료 ✅
- Terraform 기본 설정 (버전, 프로바이더)
- EC2 모듈 구현
- 공통 변수 및 프로바이더 설정
- 네이밍 규칙 정의
- S3 데모 코드

### 진행 중 🔄
- 환경별 설정 구성 (envs/)
- 솔루션 템플릿 개발
- ECS 모듈 개발

### 예정 📋
- 추가 Terraform 모듈 (ECS, S3, ELB, Route53)
- 환경별 설정 생성 (prod, stage, dev)
- 배포 스크립트 작성
- State 관리 (S3 + DynamoDB)
- CI/CD 파이프라인 통합

## Terraform 모범 사례 적용

1. **모듈 네이밍**: `terraform-<PROVIDER>-<NAME>`
2. **모듈 우선 설계**: 처음부터 모듈화를 고려한 설계
3. **버전 고정**: 명시적인 프로바이더 및 Terraform 버전 지정
4. **공통 태그**: default_tags 활용
5. **변수 분리**: 전역 변수와 모듈 변수 분리

## 사용 시나리오

### 새로운 솔루션 배포
1. `solutions/` 디렉토리에 새 솔루션 생성
2. 필요한 모듈 호출
3. 변수 설정 (이미지, 포트, 환경변수 등)
4. Terraform 실행
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

### EC2 모듈 사용 예시
```hcl
module "web_server" {
  source = "../../modules/ec2"

  ami_id             = "ami-xxxxx"
  instance_type      = "t3.micro"
  subnet_id          = "subnet-xxxxx"
  security_group_ids = ["sg-xxxxx"]
  key_name           = "my-key"
  instance_name      = "web"
  project            = var.project
  env                = var.env
}
```

## Git 상태
- **현재 브랜치**: main
- **상태**: clean
- **최근 커밋**:
  - 0b0a54a: ec2 모듈
  - 0831719: 구조 잡기
  - fada19e: 리드미 수정
  - e11c002: structure

## 다음 단계

1. **ECS 모듈 개발**
   - ecs-cluster
   - ecs-task
   - ecs-service
   - ecs-autoscaling

2. **환경별 설정 구성**
   - envs/dev/
   - envs/stage/
   - envs/prod/

3. **State 관리 설정**
   - S3 백엔드 구성
   - DynamoDB 락 테이블

4. **추가 모듈 개발**
   - VPC/네트워킹
   - RDS
   - S3
   - ELB/ALB
   - Route53

5. **자동화**
   - 배포 스크립트
   - CI/CD 파이프라인
   - 환경별 tfvars 관리

## 참고 사항

- 기본 프로젝트명: "nextpay"
- 기본 환경: "prod"
- AWS 프로바이더 버전: 5.57
- Terraform 버전: >= 1.9.0
- 모든 리소스에 자동 태그 적용: Project, Env, Owner, Managed
