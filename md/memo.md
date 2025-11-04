
테라폼은 선언형 코드
snake_cace 활용



베포시 현재의코드와 적용될 새로운 상태 코드를 일치시키는 동작을 시킴
-그렇기 때문에 변동되는게 없으면 프로비저닝안하고 변동사항이있으면 변동된 리소스만 베포를 한다.

init 은 프로바이더및 로컬세팅을함. 
plan 으로 계획 사전체크
apply 로 베포



정수= 123 # 정수 10진수
정수0시작 = 0123 # 8진수
스트링0x시작 = "0xD5" #16진수


테라폼블록 구성명시

구성명칭
resouce "<프로바이더이름_제공하는리소스>" "<동일유형의 식별자>" {}
참조 resouce.<리소스유형>.<이름>.<속성>

리소스블록 생성및관리하는 블럭  
- 리소스에서 값을 참조해서불러올경우 연관관계를갖는 종속성이 부여됨
- 강제로 종속성부여에서는 depends_on 을 활용

A를 업데이트하면 A를 참조하고있는 리소스들이 영향을받음

라이프사이클
다양한 생성,삭제 조건이있음
ignore_changes 에 포함하여 ecs 같은 경우 서비스가 변경되고 테스크데피네이션 업데이트 ㄴㄴ하게

데이터블록
- 테라폼에 정의되어있지않는 외부 리소스의 저장된 정보를 테라폼내에서 참조할때 사용
참조 data.<리소스유형>.<이름>.<속성>


입력변수
variable 은 plan 단계에서 입력함
- 우선순위 앞선 순서가 낮고 뒤로갈수록 높음.
- 인라인,디폴트,TF_VAR_환경변수이름, terraform.tfvars ( terraform.tfvars 루트모듈의 main.tf 와 같은 레벨에서 사용)


블럭안 count 는 반복 cont.index 로 인덱스번호 가져오기 가능 ( list, array 용 ) _ 생성삭제변경을 인덱스번호로 처리주의!
블럭안 for_each 는 반복  ( map,set )
블럭안 for in 는 반복 
블럭안 dynamic 는 반복 


프로비저너로 프로바이더말고 제공자 요청가능 cli 명령 등 (언제나 같다고 보장안함.)

moved 블록
state에 기록되는 주소이름 변경되면 삭제 후 생성인데 이름을 변경하되 프로비저닝된 환경을 그대로 유지하고 할때 사용

시스템환경변수
TF_LOG stderr 로그


plan 명령시 실제 형상과 비교를함. 비교안함은 -refresh-false 옵션 (ci/cd 시 수의 누군가 수동삭제해서 실제 형상비교안함.)


구성,스테이트,리소스가 있는데 코드를 삭제하면 해당 인프라를 삭제 를 뜻함



---
state 를 관리하는 논리적인 가상 공간을 워크스페이스라고함.
- 확인 명령 terraform workspace list
- 새로운 워크스페이스를 추가하면 루트모듈에 terraform.state.d 디렉토리 생성  

장점 : 하나의루트모듈에서 다양한 환경 리소스 관리, 기존 환경에 영향을 주지않고 변경 사항 관리가능
단점 : 하나의 state 가 동일 관리. 접근권한 관리, 인증 분리 어려움

루트모듈 별도구성가능

모듈디렉토리는 terraform-<프로바이더이름>-<모듈이름>


state 백앤드서버로는 HCP/ terraform (무료) __책 244~


-- 전략 --
모노리식 아키텍쳐와     마이크로서비스 아키텍쳐
개발 편리,베포간편      소규모기능 베포 테스트용이

msa 로 서로 영향을 안주게. 규모를 전체리뷰할 필요없음. 팀단위 용의


------------------------------
루트모듈 격리
├── Root Modules A/                           
│   ├── main.tf            
│   └── terraform.tfstate        (b.tfstate,c.tfstate 참조)
├── Root modules B/                     
│   ├── main.tf            
│   └── terraform.tfstate        
├── Root modules C/                     
│   ├── main.tf            
│   └── terraform.tfstate        

A 에서 B,C 사용 tfstate 는 A에서 합쳐짐.
예 B(네트워크), A (솔루션)

이때 모듈의 스테이트참조하도록 격리
------------------------------


깃브랜치기능으로 환경을 구성하기도함

Project A/
├── DEV/ (Dev Branch)                           
│   ├── main.tf            
│   └── terraform.tfstate        
├── STG/ (STG Branch)                           
│   ├── main.tf            
│   └── terraform.tfstate        
├── PROD/ (PROD Branch)                           
│   ├── main.tf            
│   └── terraform.tfstate        


CI/CD 에서
 테라폼을위해 개발된 HCP TF / TFE 환경도 있음
 개발은 로컬 apply
 prod는 pipe apply

------------------------------

예 1
    
├── modules A/ (NETWORK)                                
│       ├── DEV/ (DEV Branch)__ Root modules                            
│       │   ├── main.tf                     
│       │   └── terraform.tfstate                   
│       └── PROD/ (PROD Branch)__ Root modules                              
│           ├── main.tf                     
│           └── terraform.tfstate                   
├── modules B/    (EC2)                             
│       ├── DEV/ (DEV Branch)__ Root modules                            
│       │   ├── main.tf                     
│       │   └── terraform.tfstate                   
│       └── PROD/ (PROD Branch)__ Root modules                              
│           ├── main.tf                     
│           └── terraform.tfstate                   
└── Project C/          
        ├── DEV/ (Dev Branch)__Root modules                                 
        │   ├── main.tf                     
        │   └── terraform.tfstate     (A_DEV.tfstae, B_DEV.tfstae 참조)      
        └── PROD/ (PROD Branch)__ Root modules                              
            ├── main.tf                     
            └── terraform.tfstate   (A_PROD.tfstae, B_PROD.tfstae 참조)                 


------------------------------
예 2   오버라이드 적극활용.

DEV/
├── Root modules A/ (NETWORK)           오버라이드 적극활용.          
│   ├── main.tf            
│   └── terraform.tfstate        
├── Root modules B/    (EC2)                 
│   ├── main.tf            
│   └── terraform.tfstate    
├── Project C/  (Root 모듈 )
│       ├── main.tf            
│       └── terraform.tfstate    (A_DEV.tfstae, B_DEV.tfstae 참조) 
PROD/
├── Root modules A/ (NETWORK)                     
│   ├── main.tf            
│   └── terraform.tfstate        
├── Root modules B/    (EC2)                 
│   ├── main.tf            
│   └── terraform.tfstate    
└── Project C/  (Root 모듈 )
        ├── main.tf            
        └── terraform.tfstate    (A_PROD.tfstae, B_PROD.tfstae 참조)
  

------------------------------

예 1_1
    
├── Root modules/ (NETWORK)                     
│   ├── main.tf            
│   └── terraform.tfstate        
├── modules C/    (EC2)                 
│   ├── main.tf            
│   └── terraform.tfstate    
└── Project A/
        ├── DEV/ (Dev Branch)__Root modules                     
        │   ├── main.tf            
        │   └── terraform.tfstate        (모듈 )
        ├── STG/ (STG Branch)__ Root modules                 
        │   ├── main.tf            
        │   └── terraform.tfstate        
        └── PROD/ (PROD Branch)__ Root modules                    
            ├── main.tf            
            └── terraform.tfstate       


------------------------------
예 2-2

infra/                  
├── aws-def/                    # 실제 AWS describe로 생성 파일 (ecs구성시 참고)                  
│   ├── cluster-dev.json                    
│   ├── taskdef-dev.json                    
│   ├── service-dev.json                    
│   └── autoscal-dev.json               
│           
│DEV/           
├── modules /                             
│   ├── network/              
│   │   └── main.tf                  
│   └── EC2/                
│       └── main.tf                  
├── Network /  (Root 모듈 )        
│       ├── main.tf                 
│       └── terraform.tfstate         
├── Computing/  (Root 모듈 )        
│       ├── main.tf                 
│       └── terraform.tfstate          
├── Project C/  (Root 모듈 )        
│       ├── main.tf                 
│       └── terraform.tfstate   (DEV-Network.tfstae, DEV-Computing.tfstae 참조)         
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


------------------------------

다른기업들 HCP Terraform 사용 여부 보기. 자격요건

테스트프레임워크, 코드, 명령 구성