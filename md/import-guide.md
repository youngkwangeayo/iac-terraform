# Terraform Import 가이드

## 개요
이 가이드는 AWS 콘솔 또는 CLI로 생성된 기존 리소스를 Terraform으로 가져오는 방법과 콘솔에서 수정된 내용을 처리하는 방법을 설명합니다.

---

## Import가 필요한 경우

1. **초기 마이그레이션**: AWS 콘솔로 생성된 리소스를 Terraform으로 관리해야 할 때
2. **Drift 감지**: 콘솔에서 수정한 내용을 Terraform state와 동기화해야 할 때
3. **팀 협업**: 누군가가 수동으로 생성/수정한 리소스를 Terraform에 포함시켜야 할 때

---

## Import 작업 순서

### 1단계: 리소스 확인

AWS에는 존재하지만 Terraform에 없는 리소스 확인:

```bash
# 예시: IAM role 확인
aws iam get-role --role-name <role-name>

# 예시: Security group 확인
aws ec2 describe-security-groups --group-ids <sg-id>
```

### 2단계: Terraform 리소스 정의 작성

`.tf` 파일에 리소스 블록을 **생성하지 않고** 작성:

```hcl
# 예시: IAM Role
resource "aws_iam_role" "example" {
  name               = "example-role"
  assume_role_policy = data.aws_iam_policy_document.example.json
}
```

### 3단계: 리소스 Import

```bash
terraform import <resource_type>.<resource_name> <resource_id>
```

#### 주요 Import 예시

**IAM Role:**
```bash
terraform import aws_iam_role.ecs_task_execution ecsTaskExecutionRole
```

**IAM Role Policy Attachment:**
```bash
terraform import aws_iam_role_policy_attachment.example <role-name>/<policy-arn>

# 예시:
terraform import aws_iam_role_policy_attachment.ecs_task_cloudwatch_agent \
  ecsTaskRole/arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy
```

**Security Group:**
```bash
terraform import aws_security_group.example sg-1234567890abcdef0
```

**Security Group Rule:**
```bash
terraform import aws_security_group_rule.example sgr-1234567890abcdef0
```

**ECS Service:**
```bash
terraform import aws_ecs_service.example <cluster-name>/<service-name>
```

**ECS Task Definition:**
```bash
terraform import aws_ecs_task_definition.example <family>:<revision>
```

### 4단계: Import 검증

```bash
terraform plan
```

예상 결과:
- `No changes` = Import 성공 및 코드가 AWS 상태와 일치
- 변경사항 표시 = Terraform 코드를 AWS 리소스에 맞춰 수정 필요

### 5단계: 코드와 State 정렬

`terraform plan`이 차이를 보이면:

1. 실제 AWS 리소스 구성 확인
2. Terraform 코드를 AWS에 맞춰 수정
3. "No changes"가 나올 때까지 `terraform plan` 재실행

---

## 콘솔 변경사항 처리

### 시나리오 1: 기존 Role에 Policy 추가 (이미 Terraform 관리 중)

**상황**: 누군가 콘솔로 `ecsTaskRole`에 `CloudWatchAgentServerPolicy`를 추가함

**해결 방법**:

1. **현재 상태 확인:**
   ```bash
   aws iam list-attached-role-policies --role-name ecsTaskRole
   ```

2. **Terraform 코드에 리소스 추가:**
   ```hcl
   resource "aws_iam_role_policy_attachment" "ecs_task_cloudwatch_agent" {
     role       = aws_iam_role.ecs_task.name
     policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
   }
   ```

3. **Plan 실행:**
   ```bash
   terraform plan
   ```

4. **Terraform이 재생성하려고 하면:**
   ```bash
   terraform import aws_iam_role_policy_attachment.ecs_task_cloudwatch_agent \
     ecsTaskRole/arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy
   ```

5. **검증:**
   ```bash
   terraform plan  # "No changes" 확인
   ```

### 시나리오 2: 콘솔에서 새 리소스 생성

**상황**: 콘솔로 새로운 IAM role `custom-lambda-role` 생성됨

**해결 방법**:

1. **리소스 상세 정보 확인:**
   ```bash
   aws iam get-role --role-name custom-lambda-role
   aws iam list-attached-role-policies --role-name custom-lambda-role
   aws iam list-role-policies --role-name custom-lambda-role
   ```

2. **콘솔 구성과 일치하는 Terraform 코드 작성**

3. **Role Import:**
   ```bash
   terraform import aws_iam_role.custom_lambda custom-lambda-role
   ```

4. **모든 Attached Policy Import:**
   ```bash
   terraform import aws_iam_role_policy_attachment.custom_lambda_basic \
     custom-lambda-role/arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole
   ```

5. **검증:**
   ```bash
   terraform plan
   ```

### 시나리오 3: Security Group Rule 수정

**상황**: 기존 security group에 콘솔로 443 포트 ingress rule 추가됨

**해결 방법**:

1. **Rule ID 찾기:**
   ```bash
   aws ec2 describe-security-groups --group-ids <sg-id>
   ```

2. **Terraform에 Rule 추가:**
   ```hcl
   resource "aws_security_group_rule" "https_ingress" {
     type              = "ingress"
     from_port         = 443
     to_port           = 443
     protocol          = "tcp"
     cidr_blocks       = ["0.0.0.0/0"]
     security_group_id = aws_security_group.example.id
   }
   ```

3. **Rule Import:**
   ```bash
   terraform import aws_security_group_rule.https_ingress <rule-id>
   ```

4. **검증:**
   ```bash
   terraform plan
   ```

---

## 운영 Best Practices

### 1. 정기적인 Drift 감지

주간 또는 콘솔 변경 후 실행:

```bash
cd /path/to/terraform/module
terraform plan -detailed-exitcode
```

Exit 코드:
- `0` = 변경사항 없음 (깨끗한 상태)
- `1` = 에러 발생
- `2` = 변경사항 감지 (drift 존재)

### 2. 변경 적용 전 확인

항상 누군가 변경했을 수 있는 내용 확인:

```bash
# IAM의 경우
aws iam list-attached-role-policies --role-name <role-name>
aws iam list-role-policies --role-name <role-name>

# Security Group의 경우
aws ec2 describe-security-groups --group-ids <sg-id>

# ECS의 경우
aws ecs describe-services --cluster <cluster> --services <service>
```

### 3. 커뮤니케이션 프로토콜

누군가 콘솔 변경사항을 Terraform에 추가해달라고 요청할 때:

1. **변경사항이 존재하는지 확인:**
   ```bash
   aws <service> <describe-command>
   ```

2. **리소스가 이미 관리 중인지 확인:**
   ```bash
   terraform state list | grep <resource-name>
   ```

3. **관리 중이면**: 누락된 컴포넌트 추가 (예: policy attachment)
4. **관리 중이 아니면**: 전체 import 프로세스 진행
5. **항상 검증**: `terraform plan`으로 확인
6. **문서화**: 커밋 메시지에 변경사항 기록

### 4. 긴급 롤백

Import로 인한 문제 발생 시:

```bash
# State에서 제거 (AWS 리소스는 삭제되지 않음)
terraform state rm <resource_type>.<resource_name>

# 예시:
terraform state rm aws_iam_role_policy_attachment.ecs_task_cloudwatch_agent
```

---

## 주요 Import 패턴

### 패턴 1: 여러 Policy가 있는 IAM Role

```bash
# Role import
terraform import aws_iam_role.example example-role

# 각 Attached Managed Policy import
terraform import aws_iam_role_policy_attachment.policy1 \
  example-role/arn:aws:iam::aws:policy/Policy1

terraform import aws_iam_role_policy_attachment.policy2 \
  example-role/arn:aws:iam::aws:policy/Policy2

# Inline Policy import
terraform import aws_iam_role_policy.inline1 example-role:inline-policy-name
```

### 패턴 2: Rule이 있는 Security Group

```bash
# Security group import
terraform import aws_security_group.example sg-1234567890abcdef0

# 각 Rule 개별 import
terraform import aws_security_group_rule.ingress_https sgr-rule-id-1
terraform import aws_security_group_rule.egress_all sgr-rule-id-2
```

### 패턴 3: ECS Service 전체 Import

```bash
# Cluster import (필요한 경우)
terraform import aws_ecs_cluster.main cluster-name

# Task definition import
terraform import aws_ecs_task_definition.app family:revision

# Service import
terraform import aws_ecs_service.app cluster-name/service-name

# IAM role import (필요한 경우)
terraform import aws_iam_role.ecs_task_execution ecsTaskExecutionRole
terraform import aws_iam_role.ecs_task ecsTaskRole
```

---

## 문제 해결

### 문제: Import는 성공했지만 plan에서 변경사항 표시

**원인**: Terraform 코드가 실제 AWS 구성과 일치하지 않음

**해결책**:
1. AWS 리소스 확인: `aws <service> describe-<resource>`
2. `.tf` 파일과 비교
3. AWS에 맞춰 코드 업데이트
4. 다시 `terraform plan` 실행

### 문제: Import 실패 "resource not found"

**원인**: 잘못된 resource ID 또는 리소스가 존재하지 않음

**해결책**:
1. 리소스 존재 확인: `aws <service> describe-<resource>`
2. Terraform 문서에서 resource ID 형식 확인
3. 올바른 AWS region/account 확인

### 문제: Terraform이 Import된 리소스를 재생성하려고 함

**원인**: Identifier 불일치 또는 변경 불가능한 속성 변경됨

**해결책**:
1. State에서 제거: `terraform state rm <resource>`
2. Terraform 코드 수정
3. 재Import

---

## 빠른 참조

### 리소스 정보 확인

```bash
# IAM
aws iam get-role --role-name <name>
aws iam list-attached-role-policies --role-name <name>
aws iam list-role-policies --role-name <name>
aws iam get-role-policy --role-name <name> --policy-name <policy>

# Security Groups
aws ec2 describe-security-groups --group-ids <sg-id>
aws ec2 describe-security-group-rules --filters "Name=group-id,Values=<sg-id>"

# ECS
aws ecs describe-clusters --clusters <cluster>
aws ecs describe-services --cluster <cluster> --services <service>
aws ecs describe-task-definition --task-definition <family>:<revision>

# EC2
aws ec2 describe-instances --instance-ids <instance-id>
aws ec2 describe-volumes --volume-ids <volume-id>
```

### 주요 Import 명령어

```bash
# IAM
terraform import aws_iam_role.<name> <role-name>
terraform import aws_iam_role_policy_attachment.<name> <role-name>/<policy-arn>
terraform import aws_iam_role_policy.<name> <role-name>:<policy-name>

# Security Group
terraform import aws_security_group.<name> <sg-id>
terraform import aws_security_group_rule.<name> <rule-id>

# ECS
terraform import aws_ecs_cluster.<name> <cluster-name>
terraform import aws_ecs_service.<name> <cluster>/<service>
terraform import aws_ecs_task_definition.<name> <family>:<revision>

# EC2
terraform import aws_instance.<name> <instance-id>
terraform import aws_ebs_volume.<name> <volume-id>
```

---

## 작업 흐름도

```
콘솔 변경 감지
         |
         v
AWS CLI로 확인
         |
         v
Terraform State에 있는 리소스인가?
         |
    +----+----+
    |         |
   YES        NO
    |         |
    v         v
누락된       전체 리소스
attachment   코드 작성
추가         |
    |         v
    v      terraform
terraform    import
  plan        |
    |         v
    v      필요시 코드
필요시      조정
import       |
    |         |
    +----+----+
         |
         v
terraform plan
(No changes)
         |
         v
   Commit & Push
```

---

## 대안: Terraformer를 이용한 자동 Import (그냥참고용)

### Terraformer란?

Terraformer는 기존 인프라를 자동으로 Terraform 코드와 state로 변환해주는 CLI 도구입니다. 수동 import보다 빠르고 편리하게 여러 리소스를 한 번에 가져올 수 있습니다.

### 설치

```bash
# macOS
brew install terraformer

# 또는 직접 다운로드
curl -LO https://github.com/GoogleCloudPlatform/terraformer/releases/download/$(curl -s https://api.github.com/repos/GoogleCloudPlatform/terraformer/releases/latest | grep tag_name | cut -d '"' -f 4)/terraformer-darwin-amd64
chmod +x terraformer-darwin-amd64
sudo mv terraformer-darwin-amd64 /usr/local/bin/terraformer
```

### 기본 사용법

```bash
# 기본 형식
terraformer import aws --resources=<resource_type> --filter=<filter>

# 예시: 특정 IAM role import
terraformer import aws --resources=iam --filter=Name=my-app-role

# 예시: 특정 security group import
terraformer import aws --resources=sg --filter=Name=sg-1234567890abcdef0

# 예시: 특정 ECS cluster의 모든 리소스
terraformer import aws --resources=ecs --filter=Name=my-cluster
```

### 주요 리소스 타입별 예시

**IAM 전체 Import:**
```bash
# 특정 role만
terraformer import aws --resources=iam --filter=Role=Name=ecsTaskRole

# 모든 IAM 리소스 (주의: 매우 많을 수 있음)
terraformer import aws --resources=iam
```

**Security Group:**
```bash
# 특정 security group
terraformer import aws --resources=sg --filter=Name=sg-0123456789abcdef0

# VPC의 모든 security groups
terraformer import aws --resources=sg --filter=vpc_id=vpc-xxxxx
```

**ECS:**
```bash
# 특정 cluster의 모든 리소스
terraformer import aws --resources=ecs --filter=Name=my-cluster

# Task definition
terraformer import aws --resources=ecs --filter=Name=my-task-family
```

**EC2:**
```bash
# 특정 instance
terraformer import aws --resources=ec2_instance --filter=Name=i-1234567890abcdef0

# 특정 태그를 가진 모든 instances
terraformer import aws --resources=ec2_instance --filter=Name=tags.Environment=production
```

**VPC 관련:**
```bash
# 특정 VPC의 모든 리소스
terraformer import aws --resources=vpc,subnet,igw,nat,route_table --filter=vpc_id=vpc-xxxxx
```

### 고급 옵션

**여러 리소스 타입 동시 Import:**
```bash
terraformer import aws \
  --resources=iam,sg,ecs \
  --filter=iam:Role=Name=ecsTaskRole \
  --filter=sg:Name=sg-xxxxx \
  --filter=ecs:Name=my-cluster
```

**Region 지정:**
```bash
terraformer import aws \
  --resources=ec2_instance \
  --regions=ap-northeast-2 \
  --filter=Name=i-xxxxx
```

**출력 경로 지정:**
```bash
terraformer import aws \
  --resources=iam \
  --path-output=./imported \
  --filter=Name=my-role
```

**State 파일 생성:**
```bash
terraformer import aws \
  --resources=sg \
  --compact=true \
  --filter=Name=sg-xxxxx
```

### Terraformer 작업 흐름

```bash
# 1. 새 디렉토리 생성
mkdir -p imported-resources && cd imported-resources

# 2. Terraformer로 import
terraformer import aws --resources=iam --filter=Role=Name=ecsTaskRole

# 3. 생성된 파일 확인
ls -la
# generated/
# └── aws/
#     └── iam/
#         ├── provider.tf
#         ├── role.tf
#         ├── terraform.tfstate
#         └── variables.tf

# 4. 생성된 코드 검토 및 수정
cat generated/aws/iam/role.tf

# 5. 필요한 파일만 기존 Terraform 프로젝트로 이동
cp generated/aws/iam/role.tf ../../infra/dev/resources/iam/

# 6. State merge (필요한 경우)
terraform state pull > /tmp/current-state.json
# 수동으로 state 병합 또는 각 리소스를 개별 import
```

### Terraformer vs 수동 Import 비교

| 항목 | Terraformer | 수동 Import |
|------|-------------|-------------|
| **속도** | 빠름 (여러 리소스 동시) | 느림 (하나씩) |
| **코드 생성** | 자동 생성 | 수동 작성 필요 |
| **정확도** | 높음 (실제 리소스 기반) | 실수 가능성 있음 |
| **커스터마이징** | 생성 후 수정 필요 | 처음부터 원하는 형태로 |
| **학습 곡선** | 도구 사용법 학습 | Terraform 기본 지식 |
| **복잡한 리소스** | 효율적 | 시간 소모적 |

### Terraformer 사용 시 주의사항

1. **생성된 코드 검토 필수**
   - Terraformer가 생성한 코드는 최적화되지 않을 수 있음
   - 불필요한 속성이나 default 값들이 포함될 수 있음

2. **State 병합 주의**
   - 기존 Terraform state와 충돌 가능
   - 가능하면 새 디렉토리에서 작업 후 필요한 부분만 이동

3. **모듈화 작업**
   - 생성된 코드는 평면적 구조
   - 필요에 따라 모듈로 재구성 필요

4. **의존성 확인**
   - 리소스 간 의존성이 올바르게 설정되었는지 확인
   - 필요시 `depends_on` 추가

### 실전 예시: 전체 ECS 환경 Import

```bash
# 1. Import 디렉토리 생성
mkdir -p ~/terraformer-import/ecs-import
cd ~/terraformer-import/ecs-import

# 2. ECS 관련 모든 리소스 import
terraformer import aws \
  --resources=ecs,iam,sg,alb,target_group,listener \
  --regions=ap-northeast-2 \
  --filter=ecs:Name=my-cluster \
  --compact=true

# 3. 생성된 파일 구조 확인
tree generated/

# 4. IAM role 파일만 추출
cp generated/aws/iam/role_ecsTaskRole.tf \
   /Users/youngkwang/nextpay/infra/iac-terraform/infra/dev/resources/iam/ecs-roles/

# 5. 기존 프로젝트로 이동하여 plan 확인
cd /Users/youngkwang/nextpay/infra/iac-terraform/infra/dev/resources/iam/ecs-roles/
terraform plan

# 6. 필요시 코드 정리 및 최적화
```

### 언제 Terraformer를 사용할까?

**Terraformer 사용 권장:**
- ✅ 대량의 리소스를 한 번에 import해야 할 때
- ✅ 복잡한 리소스 구성을 import해야 할 때
- ✅ 기존 인프라 구조를 빠르게 파악하고 싶을 때
- ✅ 정확한 리소스 속성을 모를 때

**수동 Import 권장:**
- ✅ 소수의 리소스만 추가할 때
- ✅ 기존 코드 스타일을 정확히 유지하고 싶을 때
- ✅ Import 과정을 정확히 제어하고 싶을 때
- ✅ 간단한 policy attachment 등 추가할 때

---

## 주의사항

- **항상 state 백업**: `cp terraform.tfstate terraform.tfstate.backup`
- **팀 협업**: Import 전 팀원과 소통하여 충돌 방지
- **모든 것 문서화**: Import한 리소스에 대해 코드에 주석 추가
- **Drift 방지**: 팀원들에게 콘솔 대신 Terraform 사용 교육
- **Remote state 사용**: 동시 수정 문제 방지

---

## 추가 자료

- [Terraform Import 공식 문서](https://developer.hashicorp.com/terraform/cli/import)
- [AWS Provider Import 예시](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Terraformer GitHub](https://github.com/GoogleCloudPlatform/terraformer)
- [Terraformer 공식 문서](https://github.com/GoogleCloudPlatform/terraformer/blob/master/docs/aws.md)
- 프로젝트별 Import 스크립트: `/path/to/scripts/import-helpers/`
