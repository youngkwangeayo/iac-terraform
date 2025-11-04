# 프로젝트 주요 목표

## 전체 방향성

### AWS 콘솔 → Terraform 마이그레이션
기존 AWS 콘솔에서 수동으로 생성/관리하던 인프라를 Terraform 코드로 전환하여 IaC(Infrastructure as Code) 기반 관리 체계 구축

## 마이그레이션 전략

### 점진적 마이그레이션
- ❌ 한 번에 전체 인프라를 Terraform으로 전환하지 않음
- ✅ 필요할 때마다 하나씩 Terraform 모듈로 만들어가는 점진적 접근
- ✅ 각 리소스를 모듈화하여 재사용 가능하게 구성

### 대상 리소스
앞으로 Terraform으로 관리할 AWS 리소스:
- EC2 인스턴스
- 보안 그룹 (Security Groups)
- 서브넷 (Subnets)
- VPC 관련 네트워킹
- ECS 서비스 및 클러스터
- ALB/NLB (Load Balancers)
- RDS 데이터베이스
- S3 버킷
- Route53 DNS
- 기타 필요한 AWS 서비스

## 1차 목표: ECS 서비스 배포

### 목표
**Terraform을 사용하여 완전한 ECS 서비스 배포 자동화**

### 구현 범위
ECS 서비스 배포를 위해 필요한 모든 구성 요소를 Terraform 모듈로 구현:

1. **ECS 클러스터 모듈**
   - ECS 클러스터 생성
   - 클러스터 설정 및 태그

2. **ECS 태스크 정의 모듈**
   - 컨테이너 정의
   - CPU/메모리 할당
   - 환경 변수 설정
   - IAM 역할 연결

3. **ECS 서비스 모듈**
   - 서비스 생성 및 배포
   - 로드 밸런서 통합
   - 헬스 체크 설정
   - 네트워크 구성

4. **ECS Auto Scaling 모듈**
   - Target Tracking 정책
   - CPU/메모리 기반 스케일링
   - 최소/최대 태스크 수 설정

### 참조 자료
기존 AWS 콘솔에서 생성한 리소스 정의가 `aws-def/` 디렉토리에 저장되어 있음:
- `cluster-dev.json` - 클러스터 설정 참조
- `taskdef-dev.json` - 태스크 정의 참조
- `service-dev.json` - 서비스 설정 참조
- `autoscal-dev.json` - Auto Scaling 설정 참조
- `scaling-policies-dev.yaml` - 스케일링 정책 참조

### 성공 기준
- [ ] ECS 클러스터가 Terraform으로 생성됨
- [ ] ECS 태스크 정의가 코드로 관리됨
- [ ] ECS 서비스가 정상적으로 배포됨
- [ ] Auto Scaling이 정상 작동함
- [ ] 모든 구성 요소가 모듈화되어 재사용 가능함

## 장기 목표

### 모듈 라이브러리 구축
- 자주 사용하는 AWS 리소스를 모듈화
- 각 모듈은 독립적으로 사용 가능
- 모듈 간 조합으로 복잡한 인프라 구성

### 환경별 관리
- dev, stage, prod 환경 분리
- 환경별 변수 관리 (tfvars)
- 환경별 백엔드 설정

### 자동화 및 CI/CD
- Terraform plan/apply 자동화
- GitHub Actions 또는 Jenkins 통합
- 인프라 변경 리뷰 프로세스

### State 관리
- S3 백엔드를 통한 State 원격 저장
- DynamoDB를 통한 State Lock
- 팀 협업을 위한 State 공유

## 작업 순서

### Phase 1: ECS 서비스 배포 (현재)
1. ✅ 프로젝트 구조 설정
2. ✅ EC2 모듈 구현 (완료)
3. 🔄 ECS 모듈 개발 (진행 예정)
   - [ ] ecs-cluster 모듈
   - [ ] ecs-task-definition 모듈
   - [ ] ecs-service 모듈
   - [ ] ecs-autoscaling 모듈
4. [ ] 첫 번째 ECS 서비스 배포 테스트
5. [ ] 문서화 및 검증

### Phase 2: 네트워킹 및 보안 (다음)
1. [ ] VPC 모듈
2. [ ] 서브넷 모듈
3. [ ] 보안 그룹 모듈
4. [ ] NAT Gateway 모듈

### Phase 3: 로드 밸런싱 및 DNS
1. [ ] ALB/NLB 모듈
2. [ ] Target Group 모듈
3. [ ] Route53 모듈
4. [ ] ACM (인증서) 모듈

### Phase 4: 데이터베이스 및 스토리지
1. [ ] RDS 모듈
2. [ ] S3 모듈
3. [ ] ElastiCache 모듈

### Phase 5: 환경 분리 및 자동화
1. [ ] 환경별 설정 구성
2. [ ] CI/CD 파이프라인 구축
3. [ ] State 관리 체계 구축

## 원칙

### 모듈 설계 원칙
1. **단일 책임**: 하나의 모듈은 하나의 리소스 타입 관리
2. **재사용성**: 어떤 환경에서도 사용 가능하도록 설계
3. **유연성**: 변수를 통해 다양한 구성 지원
4. **명확성**: 변수명과 출력값이 명확하고 이해하기 쉬움

### 코드 작성 원칙
1. **버전 고정**: Terraform 및 Provider 버전 명시
2. **태그 표준화**: 모든 리소스에 일관된 태그 적용
3. **네이밍 규칙**: `{service}-{env}-{solution}[-{component}]` 형식 준수
4. **문서화**: 각 모듈에 README 및 사용 예시 포함

### 마이그레이션 원칙
1. **비파괴적 전환**: 기존 운영 환경에 영향 없이 전환
2. **점진적 적용**: 작은 단위부터 시작하여 검증 후 확대
3. **롤백 가능**: 문제 발생 시 이전 상태로 복구 가능
4. **검증 철저**: 각 단계마다 충분한 테스트 수행

## 현재 상태

### 완료된 작업
- ✅ 프로젝트 구조 정의
- ✅ Terraform 기본 설정 (terraform.tf, providers.tf)
- ✅ 전역 변수 정의 (variables.tf)
- ✅ EC2 모듈 구현
- ✅ 참조용 AWS 리소스 정의 수집 (aws-def/)

### 다음 작업
- 🎯 **ECS 클러스터 모듈 개발** (최우선)
- 🎯 ECS 태스크 정의 모듈 개발
- 🎯 ECS 서비스 모듈 개발
- 🎯 ECS Auto Scaling 모듈 개발
- 🎯 첫 번째 ECS 서비스 배포

## 기대 효과

### 단기 효과
- 인프라 배포 시간 단축
- 수동 작업 오류 감소
- 일관된 인프라 구성

### 장기 효과
- 인프라 변경 이력 추적 (Git)
- 팀 간 협업 향상
- 인프라 코드 재사용으로 생산성 향상
- 환경 간 일관성 보장
- 재해 복구 시간 단축
