# 작업 이력

## 📌 다음 세션에서 할 작업 (우선순위 순)

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

### 🎯 우선순위 1: Network State 생성

**목적**: 기존 VPC, Subnet 정보를 data source로 읽어 State에 저장

**작업 상세:**

1. **사전 확인**
   - AWS Console에서 실제 VPC ID 확인
   - AWS Console에서 실제 Subnet ID 확인

2. **variables.tf 업데이트** (필요 시)
   ```bash
   cd infra/dev/resources/network
   
   # variables.tf에 VPC ID, Subnet Tag 등이 정의되어 있는지 확인
   # 없으면 추가 필요
   ```

3. **Terraform 실행**
   ```bash
   cd infra/dev/resources/network
   
   # 1. 초기화
   terraform init
   
   # 2. 구문 검증
   terraform validate
   # Expected: Success! The configuration is valid.
   
   # 3. 실행 계획 확인
   terraform plan
   # Expected: data source만 읽고 리소스 생성 없음
   # 확인 사항:
   # - data.aws_vpc.main이 실제 VPC를 찾는가?
   # - data.aws_subnets.main이 실제 Subnet을 찾는가?
   
   # 4. 배포 (State 생성)
   terraform apply
   # State에 VPC, Subnet 정보 저장
   
   # 5. 출력 확인
   terraform output
   # vpc_id, subnet_ids가 올바르게 출력되는지 확인
   ```

**완료 조건:**
- [ ] VPC data source 동작 확인
- [ ] Subnet data source 동작 확인
- [ ] State 파일에 네트워크 정보 저장 완료
- [ ] outputs가 올바르게 출력됨

**문제 해결:**
- VPC를 찾지 못하면: variables.tf에서 VPC 필터 조건 수정
- Subnet을 찾지 못하면: Tag 기반 필터 조건 확인

---

### 🎯 우선순위 2: ELB State 생성

**목적**: 기존 ALB, HTTPS Listener 정보를 data source로 읽어 State에 저장

**작업 상세:**

1. **사전 확인**
   - AWS Console에서 실제 ALB ARN 확인
   - AWS Console에서 HTTPS Listener ARN 확인

2. **Terraform 실행**
   ```bash
   cd infra/dev/resources/elb
   
   # 1. 초기화
   terraform init
   
   # 2. 구문 검증
   terraform validate
   
   # 3. Remote State 참조 확인
   terraform plan
   # 확인 사항:
   # - data.terraform_remote_state.network가 동작하는가?
   # - data.aws_lb.main이 실제 ALB를 찾는가?
   # - data.aws_lb_listener.https가 실제 Listener를 찾는가?
   
   # 4. 배포
   terraform apply
   
   # 5. 출력 확인
   terraform output
   # alb_arn, https_listener_arn, security_groups가 출력되는지 확인
   ```

**완료 조건:**
- [ ] Network State 참조 성공
- [ ] ALB data source 동작 확인
- [ ] HTTPS Listener data source 동작 확인
- [ ] State 파일에 ELB 정보 저장 완료

---

### 🎯 우선순위 3: IAM Role 생성

**목적**: ECS Task 실행에 필요한 IAM Role 생성

**작업 상세:**

#### 4-1. ecsTaskExecutionRole 생성

```bash
# Trust Policy 파일 생성
cat > /tmp/ecs-task-execution-trust-policy.json << 'POLICY'
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY

# Role 생성
aws iam create-role \
  --role-name ecsTaskExecutionRole \
  --assume-role-policy-document file:///tmp/ecs-task-execution-trust-policy.json

# AWS 관리형 정책 연결
aws iam attach-role-policy \
  --role-name ecsTaskExecutionRole \
  --policy-arn arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy

# ARN 확인
aws iam get-role --role-name ecsTaskExecutionRole --query 'Role.Arn'
```

#### 4-2. ecsTaskRole 생성

```bash
# Trust Policy 파일 생성
cat > /tmp/ecs-task-trust-policy.json << 'POLICY'
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY

# Role 생성
aws iam create-role \
  --role-name ecsTaskRole \
  --assume-role-policy-document file:///tmp/ecs-task-trust-policy.json

# 필요한 정책 연결 (애플리케이션에 따라 다름)
# 예: S3 접근이 필요하면 S3 관련 정책 추가

# ARN 확인
aws iam get-role --role-name ecsTaskRole --query 'Role.Arn'
```

**완료 조건:**
- [ ] ecsTaskExecutionRole 생성 완료
- [ ] ecsTaskRole 생성 완료
- [ ] 각 Role의 ARN 확인 및 기록

---

### 🎯 우선순위 4: ECR 이미지 푸시

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
     <AWS_ACCOUNT_ID>.dkr.ecr.ap-northeast-2.amazonaws.com
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

### 🎯 우선순위 5: CMS 프로젝트 배포

**목적**: ECS 기반 CMS 애플리케이션 전체 스택 배포

**사전 조건 확인:**
- [x] Network State 생성 완료
- [x] ELB State 생성 완료
- [x] IAM Role 생성 완료
- [x] ECR 이미지 푸시 완료

**작업 상세:**

1. **variables.tf 확인 및 수정**
   ```bash
   cd infra/dev/projects/cms
   
   # variables.tf에서 다음 값들 확인:
   # - task_role_arn: IAM Role ARN
   # - execution_role_arn: IAM Role ARN
   # - container_image: ECR 이미지 URL (또는 비워두면 ECR URL 자동 사용)
   ```

2. **Terraform 실행**
   ```bash
   # 1. 초기화
   terraform init
   
   # 2. 구문 검증
   terraform validate
   
   # 3. 실행 계획 확인
   terraform plan
   # 확인 사항:
   # - Remote State 참조 (network, elb) 동작하는가?
   # - 생성될 리소스 개수가 예상과 맞는가?
   # - ECR, Security Group, Target Group, ECS Cluster, Task Definition, Service
   
   # 4. 배포
   terraform apply
   # 약 5-10분 소요 예상
   
   # 5. 출력 확인
   terraform output
   ```

3. **배포 확인**
   ```bash
   # ECS 서비스 상태 확인
   aws ecs describe-services \
     --cluster dev-cms-cluster \
     --services dev-cms-service \
     --query 'services[0].{Status:status,Running:runningCount,Desired:desiredCount}'
   
   # Task 상태 확인
   aws ecs list-tasks \
     --cluster dev-cms-cluster \
     --service-name dev-cms-service
   
   # ALB Target Group 헬스 체크 확인
   aws elbv2 describe-target-health \
     --target-group-arn <TARGET_GROUP_ARN>
   ```

**완료 조건:**
- [ ] Terraform apply 성공
- [ ] ECS Service가 Running 상태
- [ ] Task가 정상 실행 중
- [ ] Target Group Health Check 통과
- [ ] 애플리케이션 접근 가능

**문제 해결:**
- Task가 시작하지 않으면: CloudWatch Logs 확인
- Health Check 실패: Security Group 규칙 확인
- 이미지 pull 실패: IAM Role 권한 확인

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
