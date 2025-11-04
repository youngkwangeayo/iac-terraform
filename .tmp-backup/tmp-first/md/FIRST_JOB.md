# FIRST_JOB - ECS 모듈 개발 및 CMS 솔루션 구축

## 작업 개요
AWS 콘솔에서 수동 관리하던 ECS 인프라를 Terraform 모듈로 전환하는 첫 번째 작업.
목표는 재사용 가능한 ECS 모듈을 만들고, 이를 활용하여 CMS 솔루션을 코드로 구현하는 것.

## 작업 기간
- 시작: 2025-10-27
- 상태: 코드 작성 완료, 배포 대기

## 작업 내용

### 1. ECS 모듈 개발

#### 1.1 ECS Cluster 모듈 (`modules/ecs/cluster/`)
**목적**: ECS 클러스터 생성 및 Capacity Provider 설정

**주요 기능**:
- ECS 클러스터 생성
- Capacity Provider 설정 (FARGATE, FARGATE_SPOT)
- 기본 Capacity Provider 전략 설정 (옵션)

**주요 변수**:
- `cluster_name`: 클러스터 이름 (prefix 제외)
- `capacity_providers`: 사용할 Capacity Provider 리스트
- `default_capacity_provider_strategy`: 기본 전략 설정

**출력값**:
- `cluster_id`: 클러스터 ID
- `cluster_arn`: 클러스터 ARN
- `cluster_name`: 전체 클러스터 이름

**설계 이유**:
- 클러스터는 ECS의 기본 단위로, 별도 모듈로 분리하여 재사용성 확보
- Fargate와 Fargate Spot을 모두 지원하여 비용 최적화 가능

#### 1.2 ECS Task Definition 모듈 (`modules/ecs/task-definition/`)
**목적**: 컨테이너 실행 환경 정의

**주요 기능**:
- Task Definition 생성 (family, CPU, memory)
- 컨테이너 정의 (image, port, environment)
- CloudWatch Logs 자동 설정
- Health Check 설정
- 컨테이너 timeout 설정

**주요 변수**:
- `task_family`: Task Definition family 이름
- `cpu`, `memory`: Task 리소스 할당
- `task_role_arn`, `execution_role_arn`: IAM Role
- `container_name`, `container_image`: 컨테이너 설정
- `port_mappings`: 포트 매핑 리스트
- `environment_variables`: 환경 변수 맵
- `health_check_*`: 헬스 체크 관련 변수

**출력값**:
- `task_definition_arn`: Task Definition ARN
- `task_definition_family`: Family 이름
- `task_definition_revision`: Revision 번호

**설계 이유**:
- 컨테이너 정의를 JSON으로 직접 작성하지 않고 변수로 관리
- 환경 변수를 map으로 받아 동적으로 생성하여 유연성 확보
- Health Check를 옵션으로 설정 가능하게 구현
- CloudWatch Logs를 자동으로 생성하여 편의성 향상

**참조 파일**: `aws-def/taskdef-dev.json`

#### 1.3 ECS Service 모듈 (`modules/ecs/service/`)
**목적**: ECS 서비스 생성 및 배포 관리

**주요 기능**:
- ECS 서비스 생성
- Capacity Provider Strategy 설정
- 네트워크 설정 (VPC, subnet, security group)
- Load Balancer 연결
- 배포 설정 (Circuit Breaker, Rollback)
- ECS Exec 활성화

**주요 변수**:
- `service_name`: 서비스 이름
- `cluster_id`: 클러스터 ID
- `task_definition_arn`: Task Definition ARN
- `desired_count`: 원하는 태스크 수
- `capacity_provider_strategy`: Capacity Provider 전략
- `subnets`, `security_groups`: 네트워크 설정
- `load_balancers`: ALB/NLB 설정 리스트
- `deployment_*`: 배포 전략 설정

**출력값**:
- `service_id`: 서비스 ID
- `service_name`: 서비스 이름
- `service_arn`: 서비스 ARN

**설계 이유**:
- `launch_type` 대신 `capacity_provider_strategy` 사용으로 유연한 리소스 관리
- Circuit Breaker와 Rollback을 기본 활성화하여 안전한 배포
- `lifecycle` 설정으로 task_definition 변경 시 서비스 재생성 방지
- ECS Exec 기본 활성화로 디버깅 편의성 제공

**참조 파일**: `aws-def/service-dev.json`

#### 1.4 ECS Auto Scaling 모듈 (`modules/ecs/autoscaling/`)
**목적**: ECS 서비스 Auto Scaling 설정

**주요 기능**:
- Scalable Target 정의
- CPU 기반 Auto Scaling
- Memory 기반 Auto Scaling
- ALB Request Count 기반 Auto Scaling (옵션)
- Scale in/out cooldown 설정

**주요 변수**:
- `cluster_name`, `service_name`: 대상 서비스
- `min_capacity`, `max_capacity`: 최소/최대 태스크 수
- `enable_cpu_scaling`: CPU 스케일링 활성화
- `cpu_target_value`: CPU 목표 사용률 (%)
- `enable_memory_scaling`: 메모리 스케일링 활성화
- `memory_target_value`: 메모리 목표 사용률 (%)
- `scale_in_cooldown`, `scale_out_cooldown`: 쿨다운 시간

**출력값**:
- `scalable_target_id`: Scalable Target ID
- `cpu_policy_arn`: CPU 정책 ARN
- `memory_policy_arn`: Memory 정책 ARN

**설계 이유**:
- Target Tracking Scaling Policy 사용으로 자동 스케일링 구현
- CPU와 Memory를 각각 독립적으로 활성화/비활성화 가능
- Scale out은 빠르게(60초), Scale in은 천천히(300초) 설정하여 안정성 확보
- ALB Request Count 기반 스케일링은 옵션으로 제공

**참조 파일**: `aws-def/autoscal-dev.json`

### 2. CMS 솔루션 구현 (`solutions/cms/`)

#### 2.1 아키텍처
```
solutions/cms/
├── main.tf                    # 메인 구성 (모듈 호출)
├── variables.tf               # 입력 변수 정의
├── outputs.tf                 # 출력값 정의
└── terraform.tfvars.example   # 변수 예시 파일
```

#### 2.2 구성 요소
1. **ECS Cluster**: `ecs-dev-coffeezip` 클러스터 생성
2. **Task Definition**: `task-dev-coffeezip-cms` 정의
   - CPU: 512, Memory: 1024
   - Container: coffeezip-cms
   - Port: 3849
   - 환경 변수: 17개 항목 설정
3. **Service**: `service-dev-coffeezip-cms` 생성
   - Desired Count: 1
   - Fargate Capacity Provider 사용
   - 3개 서브넷, 3개 보안 그룹
   - ALB 연결 (옵션)
4. **Auto Scaling**: 1~3 태스크 범위
   - CPU 70% 목표
   - Memory 80% 목표

#### 2.3 설정 파일 (terraform.tfvars.example)
실제 배포 시 필요한 모든 변수값을 예시로 제공:
- IAM Role ARN
- 컨테이너 이미지
- 환경 변수 (17개)
- 네트워크 설정 (서브넷, 보안 그룹)
- Auto Scaling 설정

**사용 방법**:
```bash
cd solutions/cms
cp terraform.tfvars.example terraform.tfvars
# terraform.tfvars 파일 편집 후
terraform init
terraform plan
terraform apply
```

## 설계 원칙

### 모듈 설계
1. **단일 책임 원칙**: 각 모듈은 하나의 ECS 리소스만 관리
2. **재사용성**: 어떤 프로젝트에서도 사용 가능하도록 일반화
3. **유연성**: 옵션 변수 활용으로 다양한 요구사항 지원
4. **안전성**: Circuit Breaker, Rollback 등 안전장치 기본 제공

### 변수 네이밍
- 명확하고 일관된 네이밍 규칙
- 기본값 제공으로 필수 변수 최소화
- `optional()` 활용으로 선택적 속성 지원

### 태그 전략
- 모든 리소스에 `Name` 태그 자동 생성
- `extra_tags`로 추가 태그 지원
- 네이밍 규칙: `{project}-{env}-{name}`

## 주요 결정 사항

### 1. Capacity Provider vs Launch Type
**결정**: Capacity Provider Strategy 사용
**이유**:
- Fargate와 Fargate Spot 혼합 사용 가능
- 비용 최적화 용이
- 더 유연한 리소스 관리

### 2. Task Definition Container Definition 형식
**결정**: jsonencode() 사용
**이유**:
- HCL 변수를 JSON으로 동적 변환
- 조건부 속성 설정 가능 (예: health_check)
- 가독성과 유지보수성 향상

### 3. Auto Scaling 전략
**결정**: Target Tracking Scaling
**이유**:
- 설정이 간단하고 관리 용이
- AWS가 자동으로 스케일링 조정
- Step Scaling보다 직관적

### 4. Health Check 설정
**결정**: Container와 Service 레벨 모두 설정
**이유**:
- Container Health Check: 컨테이너 내부 상태 확인
- ALB Health Check: 외부 트래픽 라우팅 결정
- 이중 체크로 안정성 확보

### 5. Lifecycle 설정
**결정**: service 모듈에서 task_definition ignore
**이유**:
- Task Definition 변경 시 서비스 재생성 방지
- Blue/Green 배포 지원
- 무중단 배포 가능

## 작업 완료 항목

### 완료된 모듈
- ✅ ECS Cluster 모듈
- ✅ ECS Task Definition 모듈
- ✅ ECS Service 모듈
- ✅ ECS Auto Scaling 모듈

### 완료된 솔루션
- ✅ CMS 솔루션 코드 작성
- ✅ 변수 정의 및 예시 파일 작성
- ✅ 출력값 정의

## 다음 단계 (배포 전 체크리스트)

### 1. 사전 준비
- [ ] IAM Role 확인 (ecsTaskRole, ecsTaskExecutionRole)
- [ ] ECR 이미지 준비 확인
- [ ] VPC, 서브넷, 보안 그룹 ID 확인
- [ ] ALB Target Group ARN 확인 (로드 밸런서 사용 시)

### 2. 설정 파일 작성
- [ ] `terraform.tfvars.example`을 `terraform.tfvars`로 복사
- [ ] 모든 변수값을 실제 환경에 맞게 수정
- [ ] 민감 정보(DB 비밀번호 등) 확인

### 3. 배포 실행
```bash
# 1. 프로젝트 루트에서 Terraform 초기화
cd solutions/cms
terraform init

# 2. 계획 확인
terraform plan

# 3. 배포 (검토 후)
terraform apply

# 4. 배포 확인
terraform show
```

### 4. 배포 후 검증
- [ ] ECS 클러스터 생성 확인
- [ ] Task Definition 등록 확인
- [ ] Service 실행 확인 (desired count = running count)
- [ ] Task 헬스 체크 통과 확인
- [ ] ALB Target Health 확인 (로드 밸런서 사용 시)
- [ ] Auto Scaling Target 등록 확인
- [ ] CloudWatch Logs 스트림 생성 확인

## 트러블슈팅 가이드

### 문제: Task가 시작되지 않음
**확인 사항**:
1. Task Execution Role에 ECR pull 권한 있는지 확인
2. 서브넷이 NAT Gateway 또는 Public IP 있는지 확인
3. 보안 그룹 아웃바운드 규칙 확인

### 문제: Health Check 실패
**확인 사항**:
1. 컨테이너가 정상 실행 중인지 확인 (ECS Exec로 접속)
2. Health Check 명령어가 올바른지 확인
3. Start Period가 충분한지 확인 (앱 시작 시간)

### 문제: Load Balancer 연결 안됨
**확인 사항**:
1. Target Group ARN이 올바른지 확인
2. Container Name과 Port가 일치하는지 확인
3. 보안 그룹에서 ALB → ECS 트래픽 허용하는지 확인

### 문제: Auto Scaling 작동 안함
**확인 사항**:
1. Scalable Target이 등록되었는지 확인
2. CloudWatch Alarm이 생성되었는지 확인
3. 충분한 부하가 있는지 확인

## 참고 자료

### AWS 콘솔 참조 파일
- `aws-def/cluster-dev.json`: 클러스터 설정
- `aws-def/taskdef-dev.json`: Task Definition 설정
- `aws-def/service-dev.json`: Service 설정
- `aws-def/autoscal-dev.json`: Auto Scaling 설정

### Terraform 문서
- [AWS ECS Cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster)
- [AWS ECS Task Definition](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition)
- [AWS ECS Service](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service)
- [AWS AppAutoscaling](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_target)

## 향후 개선 사항

### 단기 (다음 작업)
1. **실제 배포 및 검증**
   - 개발 환경에 배포
   - 모든 기능 테스트
   - 문제점 파악 및 개선

2. **문서화**
   - 각 모듈에 README.md 추가
   - 사용 예시 추가
   - 변수 설명 보강

3. **추가 모듈 개발**
   - ALB/NLB 모듈
   - Target Group 모듈
   - CloudWatch Log Group 모듈

### 중기
1. **환경 분리**
   - dev, stage, prod 환경별 설정
   - Backend 설정 (S3 + DynamoDB)
   - Workspace 활용

2. **보안 강화**
   - Secrets Manager 연동
   - 환경 변수 암호화
   - IAM Policy 최소 권한 원칙

3. **모니터링**
   - CloudWatch Dashboard
   - SNS 알람 설정
   - X-Ray 트레이싱

### 장기
1. **CI/CD 통합**
   - GitHub Actions 워크플로우
   - 자동 배포 파이프라인
   - Terraform Cloud 연동

2. **고급 기능**
   - Blue/Green 배포
   - Canary 배포
   - Multi-region 지원

## 작업 소감 및 배운 점

### 설계 과정에서 배운 점
1. **모듈화의 중요성**: 작은 단위로 나누니 재사용성과 테스트 용이성이 크게 향상됨
2. **변수 설계**: optional()과 기본값을 잘 활용하면 사용자 경험이 크게 개선됨
3. **레퍼런스 활용**: AWS 콘솔 export 파일이 모듈 설계에 큰 도움이 됨

### 주의할 점
1. **State 관리**: 아직 로컬 State 사용 중, 팀 작업 시 S3 Backend 필수
2. **민감 정보**: tfvars 파일을 .gitignore에 추가 필수
3. **버전 관리**: 프로바이더 버전 고정으로 예상치 못한 변경 방지

### 다음 작업 시 개선할 점
1. Module README 작성하기
2. 변수 validation 추가하기
3. 테스트 자동화 고려하기

## 작업 로그

### 2025-10-27
- ✅ ECS 모듈 구조 설계
- ✅ Cluster 모듈 작성
- ✅ Task Definition 모듈 작성
- ✅ Service 모듈 작성
- ✅ Auto Scaling 모듈 작성
- ✅ CMS 솔루션 코드 작성
- ✅ 변수 및 출력값 정의
- ✅ terraform.tfvars.example 작성
- ✅ FIRST_JOB.md 문서화 완료

### 다음 작업 예정
- 실제 배포 및 테스트
- 문제점 수정
- 추가 모듈 개발 (ALB, Target Group 등)
