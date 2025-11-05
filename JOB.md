# 작업 이력

## 📌 다음 세션에서 할 작업 (우선순위 순)

### 🎯 우선순위 1: ECR 이미지 푸시

**목적**: CMS 컨테이너 이미지를 ECR에 푸시

**사전 조건:**
- ECR Repository가 생성되어 있어야 함 (CMS 배포 시 자동 생성됨)
- 또는 먼저 ECR만 생성하려면:
  ```bash
  cd infra/dev/projects/cms
  terraform apply -target=module.ecr
  ```

**작업 상세:**

1. **ECR 로그인**
   ```bash
   aws ecr get-login-password --region ap-northeast-2 | \
     docker login --username AWS --password-stdin \
     365485194891.dkr.ecr.ap-northeast-2.amazonaws.com
   ```

2. **Docker 이미지 빌드**
   ```bash
   # CMS 애플리케이션 디렉토리로 이동
   cd /path/to/cms/app

   # 이미지 빌드
   docker build -t dev-cms:latest .
   ```

3. **이미지 태그 및 푸시**
   ```bash
   # ECR Repository URL 확인
   ECR_URL=$(cd infra/dev/projects/cms && terraform output -raw ecr_repository_url)

   # 이미지 태그
   docker tag dev-cms:latest $ECR_URL:latest
   docker tag dev-cms:latest $ECR_URL:v1.0.0

   # 이미지 푸시
   docker push $ECR_URL:latest
   docker push $ECR_URL:v1.0.0
   ```

**완료 조건:**
- [ ] ECR 로그인 성공
- [ ] Docker 이미지 빌드 완료
- [ ] 이미지 푸시 완료
- [ ] ECR Console에서 이미지 확인

---

### 🎯 우선순위 2: CMS 프로젝트 배포

**목적**: ECS 기반 CMS 애플리케이션 전체 스택 배포

**사전 조건 확인:**
- [x] Network State 생성 완료
- [x] ELB State 생성 완료
- [x] IAM Role 생성 완료
- [ ] ECR 이미지 푸시 완료

**작업 상세:**

1. **variables.tf 확인 및 수정**
   ```bash
   cd infra/dev/projects/cms

   # variables.tf에서 다음 값들 확인:
   # - task_role_arn: arn:aws:iam::365485194891:role/ecsTaskRole
   # - execution_role_arn: arn:aws:iam::365485194891:role/ecsTaskExecutionRole
   # - container_image: ECR 이미지 URL
   ```

2. **Terraform 실행**
   ```bash
   # 1. 초기화
   terraform init

   # 2. 구문 검증
   terraform validate

   # 3. 실행 계획 확인
   terraform plan

   # 4. 배포
   terraform apply

   # 5. 출력 확인
   terraform output
   ```

3. **배포 확인**
   ```bash
   # ECS 서비스 상태 확인
   aws ecs describe-services \
     --cluster dev-cms-cluster \
     --services dev-cms-service

   # Task 상태 확인
   aws ecs list-tasks \
     --cluster dev-cms-cluster \
     --service-name dev-cms-service
   ```

**완료 조건:**
- [ ] Terraform apply 성공
- [ ] ECS Service Running
- [ ] Task 정상 실행
- [ ] Health Check 통과
- [ ] 애플리케이션 접근 가능

---

## ✅ 완료된 작업 (역순)

### 2025-11-05: IAM Role Terraform 관리 전환 완료
- [x] 기존 IAM Role 정책 확인 (ecsTaskExecutionRole, ecsTaskRole)
  - ecsTaskExecutionRole: 4개 정책
  - ecsTaskRole: 4개 정책
- [x] IAM 루트 모듈 생성 (`infra/dev/resources/iam/ecs-roles/`)
- [x] main.tf에 8개 policy attachment 모두 포함
- [x] terraform import 성공 (Role 2개 + Policy Attachment 8개)
- [x] terraform apply 성공 (태그만 추가, 정책 무손실)
- [x] S3 Backend State 저장 완료
- [x] Role ARNs 확인:
  - ecsTaskExecutionRole: arn:aws:iam::365485194891:role/ecsTaskExecutionRole
  - ecsTaskRole: arn:aws:iam::365485194891:role/ecsTaskRole

---

### ✅ 완료: S3 Backend 연동 확인

**목적**: 각 루트 모듈이 생성된 Backend를 올바르게 사용하도록 설정 확인

**✅ 완료된 작업:**
- S3 Bucket: `nextpay-terraform-state` (생성 완료)
- DynamoDB Table: `nextpay-terraform-locks` (생성 완료)
- 암호화: SSE-KMS with Bucket Key
- Versioning: Enabled
- 위치: `bootstrap/backend/` 디렉토리

**완료 내용:**

1. **Backend 설정 업데이트 완료**
   - ✅ `infra/dev/resources/network/backend.tf` 업데이트
   - ✅ `infra/dev/resources/elb/backend.tf` 업데이트
   - ✅ `infra/dev/projects/cms/backend.tf` 업데이트

   변경 사항:
   - Bucket: `terraform-state-dev-cms` → `nextpay-terraform-state`
   - DynamoDB: `terraform-lock-dev` → `nextpay-terraform-locks`

2. **Backend 초기화 성공**
   - ✅ network 모듈: `terraform init` 성공
   - ✅ elb 모듈: `terraform init` 성공
   - ✅ cms 모듈: `terraform init` 성공

---

### ✅ 완료: Network State 생성 (dev-vpc)

**목적**: 기존 VPC, Subnet 정보를 data source로 읽어 State에 저장

**완료 내용:**

1. **VPC 정보 확인 완료**
   - VPC: dev-vpc (vpc-276cc74c)
   - CIDR: 172.31.0.0/16
   - Region: ap-northeast-2

2. **main.tf 개선**
   - VPC의 모든 Subnet 자동 참조 (`data.aws_subnets`)
   - Private/Public Subnet 자동 필터링 (Name 태그 기반)
   - Private Subnet 7개 인식
   - Public Subnet 3개 인식

3. **Terraform 배포 완료**
   - ✅ terraform validate 성공
   - ✅ terraform plan 성공
   - ✅ terraform apply 성공
   - ✅ S3 Backend에 State 저장 (`s3://nextpay-terraform-state/dev/resources/network/`)

4. **Output 확인**
   - vpc_id, vpc_name, vpc_cidr
   - all_subnet_ids (10개)
   - private_subnet_ids (7개)
   - public_subnet_ids (3개)
   - private_subnet_details, public_subnet_details

---

## 📚 컨텍스트 정보

### 프로젝트 구조
```
infra/
├── modules/              # 재사용 가능한 모듈 (환경 독립적)
│   ├── common/
│   ├── ecr/
│   ├── security-group/
│   ├── target-group/
│   └── ecs/
│       ├── ecs-cluster/
│       ├── ecs-task-definition/
│       └── ecs-service/
│
└── dev/
    ├── resources/        # 공통 인프라
    │   ├── network/      # VPC, Subnet data source
    │   └── elb/          # ALB data source
    │
    └── projects/         # 프로젝트별 전용 리소스
        └── cms/          # CMS 프로젝트 전체 스택
```

### CMS 프로젝트 리소스
- **ECR Repository**: dev-cms
- **Security Group**: dev-cms-ecs
- **Target Group**: dev-cms-tg (포트 3827)
- **ECS Cluster**: dev-cms-cluster
- **ECS Task Definition**: dev-cms-task
- **ECS Service**: dev-cms-service

### AWS 리전
- **ap-northeast-2** (서울)

### 참고 문서
- [README.md](README.md) - 프로젝트 개요 및 규칙
- [tests/TEST-RESULT.md](tests/TEST-RESULT.md) - 모듈 테스트 결과

---

## ✅ 완료된 작업 (역순)

### 2025-11-05: ELB 디렉토리 구조 적용 및 State 생성
- [x] ELB 디렉토리 구조 적용 (`dev/resources/elb/nextpay/`)
- [x] backend.tf key 경로: `dev/resources/elb/nextpay/terraform.tfstate`
- [x] ALB 이름 설정: `dev-cms-elb`
- [x] Network State 참조 추가
- [x] terraform init, validate, plan, apply 성공
- [x] S3 Backend에 State 저장 완료
- [x] CMS 모듈 ELB 참조 경로 업데이트

### 2025-11-05: Network 디렉토리 구조 최종 확정 (환경별 VPC 관리)
- [x] VPC 매핑 전략 수립 및 문서화
  - dev/resources/network/nextpay/ → dev-vpc
  - prod/resources/network/nextpay/ → nextpay1-vpc (향후)
  - prod/resources/network/ai-platform/ → prod-ai-platform-vpc (향후)
- [x] 디렉토리 이름 변경: `dev-vpc` → `nextpay`
- [x] backend.tf key 경로: `dev/resources/network/nextpay/terraform.tfstate`
- [x] Subnet 필터링 개선: 소문자 `private`, `public` 매칭
- [x] S3 Backend State 마이그레이션 완료
- [x] cms 모듈의 remote state 참조 경로 수정
- [x] 이전 경로 State 파일 정리 (dev-vpc/, terraform.tfstate)
- [x] README.md VPC 매핑 테이블 및 전략 문서화

### 2025-11-05: Network State 생성 완료 (dev-vpc)
- [x] dev-vpc (vpc-276cc74c) 정보 확인
- [x] main.tf 개선: 자동 Subnet 참조 및 Private/Public 분류
- [x] terraform apply 성공
- [x] S3 Backend에 State 저장 완료
- [x] Private 7개, Public 3개 Subnet 자동 인식

### 2025-11-05: S3 Backend 연동 완료
- [x] 3개 루트 모듈 backend.tf 업데이트
  - network, elb, cms 모듈 모두 `nextpay-terraform-state` 사용
- [x] terraform init 성공 확인 (3개 모듈)

### 2025-11-05: Terraform Backend 구축 완료
- [x] S3 Bucket 생성 (`nextpay-terraform-state`)
  - Versioning, Public Access Block, SSE-KMS 암호화 설정
  - Lifecycle 정책 (30일 후 Glacier)
- [x] DynamoDB Table 생성 (`nextpay-terraform-locks`)
  - PAY_PER_REQUEST 모드, PITR 활성화
- [x] bootstrap/backend 디렉토리 구성
- [x] README.md 및 JOB.md 문서 업데이트

### 2025-11-04: README.md 및 JOB.md 구조 개선
- [x] README.md에 "현재 상태" 섹션 추가
- [x] JOB.md에 "다음 세션 작업" 섹션 추가
- [x] 구체적인 실행 명령어 및 확인 사항 작성

### 2025-11-04: CMS 배포를 위한 전체 모듈 테스트 완료
- [x] Common 모듈 테스트 (네이밍, 태그)
- [x] Security Group 모듈 테스트 (Ingress/Egress 규칙)
- [x] Target Group 모듈 테스트 (Health check)
- [x] ECS Cluster 모듈 테스트 (Capacity providers)
- [x] ECS Task Definition 모듈 테스트 (Container definitions)
- [x] 테스트 결과 TEST-RESULT.md 업데이트

### 2025-11-04: 모듈 구조 개선 - 환경 독립적 모듈 디렉토리
- [x] `infra/dev/modules/` → `infra/modules/` 이동
- [x] dev/projects/cms/main.tf 모듈 경로 수정 (7개)
- [x] 테스트 파일 모듈 경로 수정 (2개)
- [x] README.md 및 JOB.md 문서 업데이트

### 2025-11-04: 모듈 테스트 프레임워크 구축
- [x] `tests/` 디렉토리 생성
- [x] ECS Service 모듈 테스트
  - deployment_configuration 구조 오류 발견 및 수정
  - terraform validate, plan 성공
- [x] ECR 모듈 테스트 성공
- [x] TEST-RESULT.md 작성

### 2025-11-04: Phase 2 - CMS 프로젝트 ECS 배포 환경 구축 완료
- [x] 루트 모듈 관리 규칙 정립
- [x] 재사용 가능한 모듈 7개 개발
  - common, ecr, security-group, target-group
  - ecs-cluster, ecs-task-definition, ecs-service
- [x] dev/projects/cms 통합 루트 모듈 작성
- [x] 디렉토리 구조 재편성 (resources/, projects/)

### 2025-11-04: 프로젝트 구조 정리 및 README 개선
- [x] 디렉토리 구조 실제 구현
- [x] README.md 문서 개선
  - 전체 목표 섹션 정리
  - 단계별 목표 구조화
  - 디렉토리 구조 상세화
  - Terraform 모범사례 섹션 확장
  - 작업 진행 상황 섹션 추가
