# IaC 템플릿화 프로젝트  

## 전체 목표
테라폼의 IaC 템플릿으로 구성하여 모듈을 항상 유의하고개발하고 개발표준, 모범사례, 실무 표준을 따름.
AWS 인프라를 재사용 가능한 IaC 템플릿으로 구성하여, 다양한 솔루션을 빠르게 배포할 수 있도록 함.
- 네트워크등 테라폼으로 구현을 안해놓고 사용하는 리소스가 있을시 해당 리소스의 디렉토리를 만들고 루트모듈로 지정하여 data 로 aws 기존 리소스 읽어서 state 참조하는 방식으로함 추후 마이그레이션. 예 network 루트모듈 main.tf 에서 data 로 aws 기존 리소스 읽어서 관리를하고 project C에서는 network 루트모듈의 state 를 참조하는 방식으로하기.

### 첫번째 목표
- network 루트모듈 main.tf 에서 data 로 aws 기존 리소스 읽어서 관리를하고 project C에서는 network 루트모듈의 state 를 참조하는 방식으로하기.
- AWS ECS 관련해서 모듈이 필요할때, 예 ELB, ScecurityGroup.. 
- AWS ECS 한세트 베포해보기


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
- State 관리 필요 (S3 + DynamoDB)



## TODO WORKING 고려중
- 모듈 디테일화, network 안에 vpc,subnet,scuritygroup..
- data resouce 용
- dev, prod 공통으로 사용되는 코드는 오버라이드 적용