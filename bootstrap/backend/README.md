# 📘 Terraform Backend (Bootstrap)

**S3 Bucket:** `nextpay-terraform-state`  
**DynamoDB Table:** `nextpay-terraform-locks`

---

## 🧱 개요
Terraform의 상태(State) 파일을 안전하게 관리하기 위해  
AWS **S3**를 상태 저장소로, **DynamoDB**를 잠금(Lock) 관리용으로 사용합니다.  
이 디렉토리(`infra/bootstrap/backend/`)는 해당 리소스를 최초 생성하는 부트스트랩 코드입니다.

---

## 🗄️ 구성 리소스

### 📦 S3 Bucket (`nextpay-terraform-state`)
- Terraform `terraform.tfstate` 파일 저장소  
- 환경별 prefix로 state 구분 (`dev/...`, `prod/...` 등)  
- 주요 설정:
  - **Versioning:** Enabled (과거 state 복구)
  - **Public Access:** 전면 차단
  - **암호화:** SSE-KMS(`alias/aws/s3`) + **Bucket Key 활성화**
  - **Lifecycle:** 오래된 버전 30일 후 Glacier 보관
  - **Tags:**  
    `ManagedBy=terraform`, `OwnerTeam=devops`, `Purpose=terraform-backend`, `Environment=shared`

### 🔒 DynamoDB Table (`nextpay-terraform-locks`)
- Terraform의 **state 잠금(lock) 관리용 테이블**
- Hash key: `LockID` (문자열)
- 주요 설정:
  - Billing mode: `PAY_PER_REQUEST`
  - PITR(포인트인타임 복구): Enabled
  - Terraform 동시 실행 충돌 방지
  - 동일 태그 정책 적용

---

## 🔐 암호화 알고리즘 선택 이유

AWS S3는 3가지 암호화 방식을 지원합니다:
| 암호화 방식 | 설명 | 특징 |
|--------------|------|------|
| **SSE-S3** | Amazon S3 관리형 키 (AES-256) | 간단, 비용 없음 |
| **SSE-KMS** | AWS KMS 키를 사용한 암호화 | 접근제어·감사 기능 제공 |
| **DSSE-KMS** | KMS 이중 암호화 (Dual-layer) | 규제기관 대응용, 비용·지연 높음 |

### 🔸 우리 선택: **SSE-KMS + S3 Bucket Key 활성화**

#### 이유
1. **보안**  
 - KMS 기반 암호화로 접근제어 및 CloudTrail 감사 가능  
 - AWS 관리형 키(`alias/aws/s3`) 사용으로 별도 키 비용 없음  

2. **비용 효율성**  
 - `bucket_key_enabled = true` 설정으로 KMS 호출 최소화  
 - AWS 문서에 따르면 최대 **99% KMS 호출 감소**  

3. **운영 효율**  
 - 암호화/복호화 자동화  
 - CMK 키 관리 부담 없음  