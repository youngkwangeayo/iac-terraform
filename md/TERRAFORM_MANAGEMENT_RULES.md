# TERRAFORM_MANAGEMENT_RULES.md  
> **Terraform 인프라 관리 규칙서 (NEXTPAY)**  
> version: `v1.3.0`  
> 작성자: 임영광  

---

## 📘 목차

1. [디렉토리 구조 원칙](#-1-디렉토리-구조-원칙)  
2. [Root Module 및 Backend 관리 규칙](#-2-root-module-및-backend-관리-규칙)  
3. [환경 분리 원칙](#-3-환경-분리-원칙)  
4. [state 간 참조 규칙](#-4-state-간-참조-규칙)  
5. [HCP Terraform(Cloud) 사용 원칙](#-5-hcp-terraformcloud-사용-원칙)  
6. [버전 및 Provider 관리](#-6-버전-및-provider-관리)  
7. [네이밍 및 태그 규칙](#-7-네이밍-및-태그-규칙)  
8. [배포 절차 (검증 필요)](#-8-배포-절차-검증-필요)  
9. [기존 인프라 마이그레이션 절차](#-9-기존-인프라-마이그레이션-절차)  
10. [모듈 관리 원칙](#-10-모듈-관리-원칙)  
11. [요약 원칙](#-11-요약-원칙)  

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

(기존 내용 유지)

---

## 🧩 9. 기존 인프라 마이그레이션 절차

(기존 내용 유지)

---

## 🧱 10. 모듈 관리 원칙

### 📘 개요
모듈은 코드 재사용 단위로, **환경(dev/prod)과 독립적인 디렉토리에서 관리**한다.  
모듈은 state를 가지지 않으며, Root Module에서 불러와 사용한다.

### 📁 구조
```
terraform/
├── modules/
│   ├── ecs/
│   ├── network/
│   └── security/
├── dev/
│   ├── resource/
│   └── projectC/
└── prod/
    ├── resource/
    └── projectC/
```

### ✅ 규칙
| 항목 | 내용 |
|------|------|
| 모듈 위치 | `terraform/modules/` (환경 밖 전역) |
| 환경별 Root 모듈 | `terraform/dev/`, `terraform/prod/` 내 존재 |
| state 관리 | Root Module만 관리 (모듈은 state 없음) |
| 환경 차이 관리 | Root Module 변수로 전달 (`var.env`, `terraform.workspace`) |
| 버전 고정 | 필요 시 git ref나 tag로 모듈 버전 고정 |

### 📄 예시
```hcl
module "ecs" {
  source = "../../modules/ecs"
  cluster_name = "nextpay-${terraform.workspace}"
  desired_count = terraform.workspace == "prod" ? 3 : 1
}
```

### ⚙️ 장점
- 환경 간 코드 중복 제거  
- 버전 일관성 유지  
- 유지보수성 향상 (한 곳 수정 → 전체 반영)  
- Terraform 표준 구조와 일치 (HashiCorp 권장 패턴)

---

## 📘 11. 요약 원칙

✅ 환경별 디렉토리 분리 (`dev/`, `prod/`)  
✅ Root Module 단위로 backend/state 분리  
✅ 공용 리소스는 `resource/` → 멀티벤더(`aws`, `google`) 구조로 확장  
✅ `terraform.tf` 하나로 provider/version/backend 통합  
✅ state 참조는 반드시 `terraform_remote_state`  
✅ 기존 리소스는 data → import 순으로 점진적 관리 전환  
✅ 모듈은 환경 밖 전역 디렉토리에서 관리  
✅ CI/CD 및 배포 단계는 검증 후 확정  
