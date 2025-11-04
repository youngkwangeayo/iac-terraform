# TERRAFORM_MANAGEMENT_RULES.md  
> **Terraform 인프라 관리 규칙서 (NEXTPAY)**  
> version: `v1.2.0`  
> 작성자: 임영광  

---

## 🧱 1. 디렉토리 구조 원칙

### 기본 구조
```
terraform/
├── modules/                        # 재사용 모듈 (state 없음)
│   ├── network/
│   ├── ec2/
│   └── security/
├── dev/
│   ├── resource/
│   │   ├── network/
│   │   └── security/
│   ├── computing/
│   └── projectC/
└── prod/
    ├── resource/
    ├── computing/
    └── projectC/
```

### 벤더 환경 추가 시 (마이그레이션 구조)
```
terraform/
├── dev/
│   ├── resource/
│   │   ├── aws/
│   │   │   ├── network/
│   │   │   └── security/
│   │   └── google/
│   │       └── network/
│   ├── computing/
│   └── projectC/
```

✅ **규칙 요약**
- `modules/` → 코드 재사용 전용 (state 없음)  
- `dev/`, `prod/` → 환경 단위 Root 모듈  
- `resource/` → 인프라팀 공용 리소스 (Network, SecurityGroup, IAM 등)  
- `project*` → 서비스팀 전용 리소스  
- 디렉토리 리팩토링 시 `backend key` 유지 시 state 영향 없음  

---

## 🧩 2. Root Module 및 Backend 관리 규칙

### 구성 파일
```
main.tf          # 리소스 정의 및 모듈 호출
terraform.tf     # provider, version, backend 설정 (통합 관리)
variables.tf     # 입력 변수 정의
outputs.tf       # 출력값 정의
```

### 예시
```hcl
terraform {
  required_version = ">= 1.13.4"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.18.0"
    }
  }

  backend "s3" {
    bucket         = "nextpay-terraform-state"
    key            = "dev/resource/security/terraform.tfstate"
    region         = "ap-northeast-2"
    dynamodb_table = "nextpay-terraform-locks"
    encrypt        = true
  }
}

provider "aws" {
  region = "ap-northeast-2"
}
```

✅ **원칙**
| 항목 | 내용 |
|------|------|
| backend 단위 | Root 모듈별 개별 관리 |
| backend 구성 | S3 + DynamoDB 조합 |
| key 규칙 | `<환경>/<리소스이름>/terraform.tfstate` |
| provider/version/backend | `terraform.tf` 하나로 통합 관리 |
| state 저장소 이동 | key 동일 시 영향 없음 |
| DynamoDB | 환경 공용 사용 가능 |

---

## 🌍 3. 환경 분리 원칙

| 항목 | 내용 |
|------|------|
| 환경 구분 | `dev/`, `prod/`, `stg/` 물리적 폴더 분리 |
| state 관리 | 환경별 완전 독립 |
| 환경 추가 | 디렉토리 복사 + backend key 변경 |
| 실행 기준 | 환경 단위 `terraform init → plan → apply` |

---

## 🔗 4. state 간 참조 규칙

### 예시: projectC → security-group 참조

```hcl
# dev/projectC/main.tf
data "terraform_remote_state" "security" {
  backend = "s3"
  config = {
    bucket = "nextpay-terraform-state"
    key    = "dev/resource/aws/security/terraform.tfstate"
    region = "ap-northeast-2"
  }
}

resource "aws_instance" "app" {
  ami           = "ami-0123456789abcdef"
  instance_type = "t3.micro"
  vpc_security_group_ids = [
    data.terraform_remote_state.security.outputs.sg_app_id
  ]
  subnet_id = "subnet-0abc1234def56789a"
}
```

```hcl
# dev/resource/aws/security/main.tf
resource "aws_security_group" "app" {
  name   = "app-sg"
  vpc_id = "vpc-1234567890abcdef"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "sg_app_id" {
  value = aws_security_group.app.id
}
```

✅ **원칙**
| 항목 | 설명 |
|------|------|
| Root 모듈 간 참조 | `terraform_remote_state` 사용 |
| 동일 state 내 코드 재사용 | `module` 블록 사용 |
| state 경로 유지 | key 동일 시 문제 없음 |
| cross-state 참조 | 반드시 명시적 정의 (`data.terraform_remote_state`) |

---

## ☁️ 5. HCP Terraform(Cloud) 사용 원칙

| 항목 | 규칙 |
|------|------|
| workspace 단위 | Root 모듈별 생성 (`dev-aws-network`, `dev-aws-security`) |
| organization | 동일 조직(`nextpay`) 사용 |
| cloud backend | 각 Root 모듈에 개별 선언 |
| state 이동 | 필요 시 `terraform state push/pull` 활용 가능 |

---

## 🧱 6. 버전 및 Provider 관리

```hcl
terraform {
  required_version = ">= 1.13.4"
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
```

✅ **규칙**
| 항목 | 내용 |
|------|------|
| Terraform 버전 | 루트별 동일 버전 유지 |
| Provider 버전 | 루트별 명시, 충돌 방지 |
| 통합 버전 관리 | `.terraform-version` 또는 CI 파이프라인에서 관리 |
| 업그레이드 정책 | dev → stg → prod 순차 반영 |

---

## 🔐 7. 네이밍 및 태그 규칙

| 항목 | 예시 |
|------|------|
| S3 key | `dev/resource/aws/security/terraform.tfstate` |
| DynamoDB table | `nextpay-terraform-locks` |
| HCP workspace | `dev-aws-security`, `prod-aws-network` |
| 공통 태그 | `ManagedBy=terraform`, `Env=dev`, `Owner=infra` |

---

## ⚙️ 8. 배포 절차 (검증 필요)

### 🔹 개발 배포
| 단계 | 수행자 | 환경 | 동작 |
|------|----------|------|------|
| 1 | 개발자 | **로컬** | 코드 작성 → `plan/apply` → 기능 테스트 |
| 2 | 개발자 | **GitHub Action / Pipeline** | (필요 시) `plan/apply` 또는 트리거 실행 |
| 3 | 개발자 | **Terraform Cloud (개발 서버)** | plan/apply 실행 및 검증 완료 |

### 🔹 운영 배포
| 단계 | 수행자 | 환경 | 동작 |
|------|----------|------|------|
| 1 | 인프라담당자 또는 PM | **GitHub Action / Pipeline** | plan/apply 실행 승인 |
| 2 | 인프라담당자 또는 PM | **Terraform Cloud (운영 서버)** | plan/apply 실행 및 검증 완료 |

⚠️ **비고:**  
- 배포 절차는 **피드백 및 검증 필요 항목**으로 분류됨  
- CI/CD 승인 정책 확정 시 재정의 예정  

---

## 🧩 9. 기존 인프라 마이그레이션 절차

### 📘 목적
기존에 수동으로 생성된 AWS 리소스(VPC, Subnet, SG 등)를 Terraform 관리 대상으로 점진적으로 전환하는 절차.

---

### 1️⃣ 초기 상태
- `resource/network` Root 모듈 존재하지만 Terraform 리소스 정의 없음.  
- 기존 AWS 리소스는 수동으로 생성되어 있으며 state에 포함되지 않음.

---

### 2️⃣ Data Source 기반 관리 시작
**단계 A: data로 읽어서 루트모듈 구성**
```hcl
# dev/resource/aws/network/main.tf
data "aws_vpc" "main" {
  id = "vpc-0123456789abcdef"
}

data "aws_subnet" "public_a" {
  id = "subnet-0a1b2c3d4e5f67890"
}

output "vpc_id" {
  value = data.aws_vpc.main.id
}
output "subnet_id" {
  value = data.aws_subnet.public_a.id
}
```
- `terraform apply` 실행 시 **state에는 data 정보만 기록**됨.  
- 실제 리소스 변경 없음.

---

### 3️⃣ 다른 모듈에서 참조
```hcl
# dev/projectC/main.tf
data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "nextpay-terraform-state"
    key    = "dev/resource/aws/network/terraform.tfstate"
    region = "ap-northeast-2"
  }
}

resource "aws_instance" "app" {
  ami           = "ami-0123456789abcdef"
  instance_type = "t3.micro"
  subnet_id     = data.terraform_remote_state.network.outputs.subnet_id
}
```
- projectC는 network state output을 참조하므로, 이후 network 코드화 시 수정 불필요.

---

### 4️⃣ Import를 통한 마이그레이션 전환
**단계 B: import로 기존 리소스를 Terraform 관리로 전환**
```bash
terraform init
terraform import aws_vpc.main vpc-0123456789abcdef
terraform import aws_subnet.public_a subnet-0a1b2c3d4e5f67890
```

- 리소스 주소는 `resource "<type>" "<name>"` 구조를 따름.  
- 예: `aws_vpc.main`, `aws_subnet.public_a`

**import 후 검증**
```bash
terraform plan
```
출력 예시:
```
No changes. Infrastructure is up-to-date.
```
✅ → Terraform이 기존 리소스를 인식하고 관리 상태로 전환됨.

---

### 5️⃣ 최종 상태
| 단계 | 결과 |
|------|------|
| data 참조 | 기존 리소스 읽기 전용 |
| import 완료 | Terraform이 해당 리소스를 state에 등록 |
| 이후 plan/apply | Terraform이 리소스를 완전 관리 (IaC 완성) |

---

✅ **운영 규칙**
| 항목 | 설명 |
|------|------|
| data 참조 단계 | 안전하게 구조 검증 가능 (읽기 전용) |
| import 단계 | 기존 리소스를 Terraform 관리 대상으로 전환 |
| 이후 운영 | Terraform state 기반 관리로 일원화 |

---

## 📘 부록: 요약 원칙

✅ 환경별 디렉토리 분리 (`dev/`, `prod/`)  
✅ Root Module 단위로 backend/state 분리  
✅ 공용 리소스는 `resource/` → 멀티벤더(`aws`, `google`) 구조로 확장  
✅ `terraform.tf` 하나로 provider/version/backend 통합  
✅ state 참조는 반드시 `terraform_remote_state`  
✅ 기존 리소스는 data → import 순으로 점진적 관리 전환  
✅ 디렉토리 리팩토링 시 key 유지로 state 안정성 확보  
✅ CI/CD 및 배포 단계는 검증 후 확정  
