# Common Module

공통 네이밍 규칙과 태그를 관리하는 모듈입니다.

## 기능

- 일관된 리소스 네이밍 규칙 제공
- 공통 태그 자동 생성
- 환경, 프로젝트, 서비스, 컴포넌트별 네이밍 조합 지원

## 네이밍 규칙

### 기본 형식
```
{environment}-{project_name}
```

### 서비스 포함 형식
```
{environment}-{aws_service}-{project_name}
```

### 전체 형식 (컴포넌트 포함)
```
{environment}-{aws_service}-{project_name}-{component}
```

## 사용 예시

### 기본 사용 (프로젝트 레벨)
```hcl
module "common" {
  source = "../../modules/common"

  environment  = "dev"
  project_name = "cms"
}

# Output: name_prefix = "dev-cms"
# Output: common_tags = {
#   Environment = "dev"
#   Project     = "cms"
#   ManagedBy   = "Terraform"
# }
```

### AWS 서비스 포함
```hcl
module "common" {
  source = "../../modules/common"

  environment  = "dev"
  project_name = "cms"
  aws_service  = "ecs"
}

# Output: service_prefix = "dev-ecs-cms"
```

### 컴포넌트 포함
```hcl
module "common" {
  source = "../../modules/common"

  environment  = "dev"
  project_name = "cms"
  aws_service  = "ecs"
  component    = "api"
}

# Output: full_name = "dev-ecs-cms-api"
```

### 추가 태그 병합
```hcl
module "common" {
  source = "../../modules/common"

  environment  = "dev"
  project_name = "cms"

  additional_tags = {
    Owner = "platform-team"
    Cost  = "shared"
  }
}

# Output: common_tags = {
#   Environment = "dev"
#   Project     = "cms"
#   ManagedBy   = "Terraform"
#   Owner       = "platform-team"
#   Cost        = "shared"
# }
```

## 실제 사용 예시 (dev/projects/cms)

```hcl
module "common" {
  source = "../../modules/common"

  environment  = var.environment
  project_name = var.project_name
}

locals {
  name_prefix = module.common.name_prefix
  common_tags = module.common.common_tags
}

# ECR 생성
module "ecr" {
  source = "../../modules/ecr"

  repository_name = local.name_prefix  # "dev-cms"
  tags            = local.common_tags
}

# ECS Cluster 생성
module "ecs_cluster" {
  source = "../../modules/ecs-cluster"

  cluster_name = "${local.name_prefix}-cluster"  # "dev-cms-cluster"
  tags         = local.common_tags
}
```

## Outputs

| Name | Description | Example |
|------|-------------|---------|
| name_prefix | 기본 네임 prefix | `dev-cms` |
| service_prefix | 서비스 포함 prefix | `dev-ecs-cms` |
| full_name | 전체 리소스 이름 | `dev-ecs-cms-api` |
| common_tags | 공통 태그 맵 | `{Environment="dev", ...}` |
| environment | 환경 이름 | `dev` |
| project_name | 프로젝트 이름 | `cms` |
