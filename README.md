# IaC 템플릿화 프로젝트  

## 목표
테라폼의 IaC 템플릿으로 구성하여 모듈을 항상 유의하고개발하고 개발표준, 모범사례, 실무 표준을 따름.
AWS 인프라를 재사용 가능한 IaC 템플릿으로 구성하여, 다양한 솔루션을 빠르게 배포할 수 있도록 함
AWS ECS 한세트 베포해보기

## 네이밍 규칙
**형식**: `{aws-service}-{environment}-{solution}[-{component}]`

### 예시
- `ecs-dev-myapp`
- `ecs-dev-mys1-api`
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
│DEV/           
├── modules /  (Root 모듈 )                           
│   ├── network/              
│   │   ├── main.tf                  
│   │   └── terraform.tfstate       
│   └── EC2/  (Root 모듈 )              
│       ├── main.tf                  
│       └── terraform.tfstate   
├── Project C/  (Root 모듈 )        
│       ├── main.tf                 
│       └── terraform.tfstate    (DEV-network.tfstae, DEV-EC2.tfstae 참조)      
PROD/       
├── Root modules A/ (NETWORK)                           
│   ├── main.tf                 
│   └── terraform.tfstate               
├── Root modules B/    (EC2)                        
│   ├── main.tf                 
│   └── terraform.tfstate           
└── Project C/  (Root 모듈 )        
        ├── main.tf                 
        └── terraform.tfstate     (PROD-network.tfstae, PROD-EC2.tfstae 참조)           
```

## Terraform 모범사례
- **모듈에서 이름규칙은**: `terraform-<PROVIDER>-<NAME>`
- **모듈을 염두에 두고 구성 작성을 시작하세요**



### Terraform
- **장점**: 멀티 클라우드 지원, HCL 문법, 강력한 모듈 시스템, Plan 기능
- **단점**: State 관리 필요 (S3 + DynamoDB)
- **상태**: 🔄 구현 예정

## 사용 시나리오

### 새로운 솔루션 배포
1. Values/환경 파일 복사
2. 설정 수정 (이미지, 포트, 환경변수 등)
3. 배포 실행



### Terraform 방식 (예정)
```bash
terraform init
terraform plan
terraform apply
```

## 다음 단계
- [ ] Terraform 모듈 구현
- [ ] Terraform 환경별 설정 생성
- [ ] 배포 스크립트 작성
- [ ] CI/CD 파이프라인 통합