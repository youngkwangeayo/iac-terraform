# Common Module

공통 네이밍 규칙과 태그를 관리하는 모듈입니다.

## 기능

- 일관된 리소스 네이밍 규칙 제공
- 공통 태그 자동 생성
- 환경, 프로젝트, 서비스별 네이밍 조합 지원

## 네이밍 규칙

### 네이밍 형식
```
{environment}-{project_name}[-{service_name}]
```

- `environment`: 환경 구분 (dev, stg, prod)
- `project_name`: 프로젝트/솔루션 이름 (cms, payment 등)
- `service_name`: 서비스 이름 (선택 사항, api, web, worker 등)

### 예시
| environment | project_name | service_name | 결과 (`common_name`) |
|------------|--------------|--------------|---------------------|
| dev | cms | null | `dev-cms` |
| dev | cms | api | `dev-cms-api` |
| prod | payment | web | `prod-payment-web` |
| stg | logbackend | null | `stg-logbackend` |

### 모듈에서의 리소스 네이밍

common 모듈은 기본 이름만 제공하며, 각 재사용 모듈에서 AWS 서비스 접두어를 붙입니다.

**네이밍 패턴**: `{aws-service}-{common_name}`

예시:
```hcl
# common 모듈 출력
common_name = "dev-cms"

# 각 모듈에서 적용
- ECR: ecr-dev-cms
- ECS Cluster: cluster-dev-cms
- ECS Service: service-dev-cms
- Security Group: sg-dev-cms
- Target Group: tg-dev-cms
```

## 입력 변수

| 변수명 | 타입 | 필수 | 기본값 | 설명 |
|--------|------|------|--------|------|
| environment | string | O | - | 환경 (dev, stg, prod) |
| project_name | string | X | null | 프로젝트 이름 |
| service_name | string | X | null | 서비스 이름 |
| additional_tags | map(string) | X | {} | 추가 태그 |

## 출력값

| 출력명 | 설명 | 예시 |
|--------|------|------|
| common_name | 조합된 공통 이름 | `dev-cms` 또는 `dev-cms-api` |
| common_tags | 공통 태그 맵 | `{ Environment = "dev", Project = "cms", ManagedBy = "Terraform" }` |
| environment | 환경 이름 | `dev` |

## 사용 예시

### 기본 사용 (프로젝트 레벨)
```hcl
module "common" {
  source = "../../../modules/common"

  environment  = "dev"
  project_name = "cms"
}

# Output:
# common_name = "dev-cms"
# common_tags = {
#   Environment = "dev"
#   Project     = "cms"
#   ManagedBy   = "Terraform"
# }
```

### 서비스 이름 포함
```hcl
module "common" {
  source = "../../../modules/common"

  environment  = "dev"
  project_name = "cms"
  service_name = "api"
}

# Output: common_name = "dev-cms-api"
```

### 추가 태그 병합
```hcl
module "common" {
  source = "../../../modules/common"

  environment  = "dev"
  project_name = "cms"

  additional_tags = {
    Team  = "Platform"
    Owner = "DevOps"
  }
}

# Output: common_tags = {
#   Environment = "dev"
#   Project     = "cms"
#   ManagedBy   = "Terraform"
#   Team        = "Platform"
#   Owner       = "DevOps"
# }
```

## 실제 사용 예시 (dev/projects/cms)

```hcl
# 1. Common 모듈로 공통 이름과 태그 생성
module "common" {
  source = "../../../modules/common"

  environment  = var.environment   # "dev"
  project_name = var.project_name  # "cms"
}

# 2. 재사용 모듈에서 common_name과 common_tags 사용
module "ecr" {
  source = "../../../modules/ecr"

  repository_name = module.common.common_name  # ECR 모듈 내부에서 "ecr-dev-cms"로 생성
  tags            = module.common.common_tags
}

module "ecs_cluster" {
  source = "../../../modules/ecs/ecs-cluster"

  cluster_name = module.common.common_name  # ECS Cluster 모듈 내부에서 "cluster-dev-cms"로 생성
  tags         = module.common.common_tags
}

module "ecs_security_group" {
  source = "../../../modules/security-group"

  name   = module.common.common_name  # Security Group 모듈 내부에서 "sg-dev-cms"로 생성
  vpc_id = data.terraform_remote_state.network.outputs.vpc_id
  tags   = module.common.common_tags
}

module "target_group" {
  source = "../../../modules/load-balancer/target-group"

  name   = module.common.common_name  # Target Group 모듈 내부에서 "tg-dev-cms"로 생성
  vpc_id = data.terraform_remote_state.network.outputs.vpc_id
  tags   = module.common.common_tags
}
```

## 실제 생성된 AWS 리소스 이름

위 예시로 생성된 실제 리소스 이름:

| AWS 서비스 | Terraform 리소스 | 실제 AWS 이름 |
|-----------|-----------------|--------------|
| ECR Repository | `module.ecr` | `ecr-dev-cms` |
| ECS Cluster | `module.ecs_cluster` | `cluster-dev-cms` |
| ECS Service | `module.ecs_service` | `service-dev-cms` |
| ECS Task Definition | `module.ecs_task_definition` | `dev-cms` (family) |
| Security Group | `module.ecs_security_group` | `sg-dev-cms` |
| Target Group | `module.target_group` | `tg-dev-cms` |
| CloudWatch Log Group | `aws_cloudwatch_log_group.ecs` | `/ecs/dev-cms` |

## 장점

1. **일관성**: 모든 리소스가 통일된 네이밍 규칙을 따름
2. **추적성**: 환경과 프로젝트를 이름에서 바로 식별 가능
3. **재사용성**: 변수만 변경하면 다른 프로젝트에 적용 가능
4. **태그 자동화**: ManagedBy, Environment, Project 태그 자동 생성
5. **유연성**: service_name으로 서비스 단위 확장 가능
