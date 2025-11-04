# IaC 템플릿화 프로젝트  

## 목표
테라폼의 IaC 템플릿으로 구성하여 모듈을 항상 유의하고개발하고 개발표준, 모범사례, 실무 표준을 따름.
AWS 인프라를 재사용 가능한 IaC 템플릿으로 구성하여, 다양한 솔루션을 빠르게 배포할 수 있도록 함
AWS ECS 한세트 베포해보기

## 네이밍 규칙
**형식**: `{aws-service}-{environment}-{solution}[-{component}]`

### 예시
- `ecs-dev-myapp`
- `service-dev-mys1-api`
- `ecs-prod-payment-web`
- `rds-dev-myapp`

## 디렉토리 구조

```


infra/                  
├── aws-def/                    # 실제 AWS describe로 생성 파일 (ecs구성시 참고)                  
│   ├── cluster-dev.json                    
│   ├── taskdef-dev.json                    
│   ├── service-dev.json                    
│   └── autoscal-dev.json               
│           
dev/           
├── modules /                             
│   ├── network/              
│   │   └── main.tf                  
│   └── EC2/                
│       └── main.tf                  
├── network /  (Root 모듈 )        
│       ├── main.tf                 
│       └── terraform.tfstate         
├── computing/  (Root 모듈 )        
│       ├── main.tf                 
│       └── terraform.tfstate          
├── project C/  (Root 모듈 )        
│       ├── main.tf                 
│       └── terraform.tfstate   (DEV-Network.tfstae, DEV-Computing.tfstae 참조)         
prod/       
│ ...같은구조

```

## Terraform 모범사례
- **모듈에서 이름규칙은**: `terraform-<PROVIDER>-<NAME>`
- **모듈을 염두에 두고 구성 작성을 시작하세요**



### Terraform
- **장점**: 멀티 클라우드 지원, HCL 문법, 강력한 모듈 시스템, Plan 기능
- **단점**: State 관리 필요 (S3 + DynamoDB)
- **상태**: 🔄 구현 예정

