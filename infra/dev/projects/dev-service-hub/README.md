# dev-service-hub EKS Cluster

signage, cms, aiagent 개발 클러스터를 하나로 통합한 EKS 클러스터입니다.

- **Cluster Name**: `eks-dev-service-hub`
- **Kubernetes Version**: 1.35
- **Node Groups**: infra / signage / cms / aiagent (4개)
- **Node Type**: t3.large (각 1-2 nodes, desired: 1)
- **Service CIDR**: 10.200.0.0/16
- **Network**: vpc-276cc74c

---

## Node Group 구조

### 노드그룹 목록

| 노드그룹 | Taint | 용도 |
|---------|-------|------|
| `nodegroup-dev-service-hub-infra` | `service=infra:NoSchedule` | 클러스터 공용 인프라 Pod |
| `nodegroup-dev-service-hub-signage` | `service=signage:NoSchedule` | Signage 서비스 전용 |
| `nodegroup-dev-service-hub-cms` | `service=cms:NoSchedule` | CMS 서비스 전용 |
| `nodegroup-dev-service-hub-aiagent` | `service=aiagent:NoSchedule` | AI Agent 서비스 전용 |

### Pod 배치 구조

```
전체 노드 (DaemonSet)
├── vpc-cni              EKS 관리형, operator:Exists toleration 내장
├── kube-proxy           EKS 관리형, operator:Exists toleration 내장
├── ebs-csi-node         볼륨 마운트용, operator:Exists toleration 내장
└── node-exporter        모든 노드 메트릭 수집

infra 노드
├── coredns              클러스터 DNS
├── ebs-csi-controller   EBS 볼륨 프로비저닝 컨트롤러
├── metrics-server       리소스 메트릭
├── alb-controller       Ingress/ALB 관리
├── cluster-autoscaler   노드 오토스케일링
├── prometheusOperator
├── prometheus
├── grafana              grafana-dev-service-hub.nextpay.co.kr
└── alertmanager

signage 노드   → signage 서비스 Pod만
cms 노드       → cms 서비스 Pod만
aiagent 노드   → aiagent 서비스 Pod만
```

### 서비스 Deployment 필수 설정

서비스 Pod를 전용 노드에만 배포하려면 아래 설정을 Deployment에 추가합니다.

```yaml
spec:
  template:
    spec:
      tolerations:
        - key: "node-role"
          value: "signage"   # cms | aiagent
          effect: "NoSchedule"
      nodeSelector:
        node-role: signage   # cms | aiagent
```

---

## File Structure

```
dev-service-hub/
├── terraform.tf           Providers & S3 backend
├── variables.tf           변수 정의
├── terraform.tfvars       설정값
├── data.tf                데이터 소스
├── locals.tf              공통 모듈 & 태그
├── main.tf                공통 모듈 호출
├── iam-cluster.tf         EKS 클러스터 IAM 역할
├── iam-node.tf            노드그룹 IAM 역할
├── iam-irsa.tf            IRSA (ALB Controller, EBS CSI, Cluster Autoscaler)
├── security-groups.tf     보안 그룹
├── eks-cluster.tf         EKS 클러스터 리소스
├── eks-nodegroup.tf       서비스별 노드그룹 (for_each)
├── eks-addons.tf          EKS 관리형 애드온
├── helm-addons.tf         Helm 애드온
├── route53-recode.tf      Route53 DNS 레코드
├── outputs.tf             출력값
├── policies/
│   └── alb-controller-policy.json
└── values/
    └── kube-prometheus-stack-values.yaml
```

---

## Deployment

### 1. 초기화

```bash
cd infra/dev/projects/dev-service-hub
terraform init
```

### 2. 플랜 확인 및 적용

```bash
terraform plan -out=tfplan
terraform apply tfplan
```

**예상 소요 시간**: EKS 클러스터 + 노드그룹 4개 + Helm 애드온 = 약 30-40분

### 3. kubectl 설정

```bash
aws eks update-kubeconfig --region ap-northeast-2 --name eks-dev-service-hub
kubectl get nodes --show-labels
```

### 4. 노드그룹 및 taint 확인

```bash
# 노드그룹 4개 확인
aws eks list-nodegroups --cluster-name eks-dev-service-hub --region ap-northeast-2

# 노드 레이블 및 taint 확인
kubectl get nodes --show-labels
kubectl get nodes -o json | jq '.items[] | {name: .metadata.name, taints: .spec.taints}'

# 서비스별 노드 확인
kubectl get nodes -l Service=infra
kubectl get nodes -l Service=signage
kubectl get nodes -l Service=cms
kubectl get nodes -l Service=aiagent
```

### 5. 시스템 Pod 배치 확인

```bash
# infra 노드 배치 확인
kubectl get pods -n kube-system -o wide
kubectl get pods -n monitoring -o wide

# node-exporter가 전체 노드에 올라왔는지 확인
kubectl get pods -n monitoring -l app.kubernetes.io/name=prometheus-node-exporter -o wide
```

### 6. Grafana Route53 업데이트

Grafana ALB가 생성되면 DNS 레코드를 업데이트합니다.

```bash
# ALB DNS 확인
kubectl get ingress -n monitoring

# terraform.tfvars의 route53_records.records 값을 ALB DNS로 수정 후 재적용
terraform apply
```

---

## Included Components

### EKS Managed Add-ons
| 애드온 | 배치 | 비고 |
|-------|------|------|
| vpc-cni | 전체 노드 | DaemonSet, toleration 내장 |
| kube-proxy | 전체 노드 | DaemonSet, toleration 내장 |
| ebs-csi-node | 전체 노드 | DaemonSet, toleration 내장 |
| coredns | infra 노드 | `nodeSelector: Service=infra` |
| ebs-csi-controller | infra 노드 | `nodeSelector: Service=infra`, IRSA 적용 |

### Helm Add-ons
| 차트 | 배치 | 비고 |
|-----|------|------|
| metrics-server | infra 노드 | |
| aws-load-balancer-controller | infra 노드 | IRSA 적용 |
| cluster-autoscaler | infra 노드 | IRSA 적용 |
| kube-prometheus-stack | infra 노드 | node-exporter만 전체 노드 |

---

## Troubleshooting

### Pod가 Pending 상태인 경우

```bash
kubectl describe pod <pod-name> -n <namespace>
# Events에서 taint/toleration 불일치 또는 nodeSelector 미매칭 확인
```

서비스 Pod → toleration + nodeSelector 설정 확인 (위 "서비스 Deployment 필수 설정" 참고)

### 노드그룹 상태 확인

```bash
aws eks describe-nodegroup \
  --cluster-name eks-dev-service-hub \
  --nodegroup-name nodegroup-dev-service-hub-infra \
  --region ap-northeast-2
```

### IRSA 확인

```bash
kubectl get serviceaccount -n kube-system aws-load-balancer-controller -o yaml
terraform output alb_controller_role_arn
```

---

## Cost Estimate (Seoul Region, 월)

| 항목 | 비용 |
|-----|-----|
| EKS Control Plane | $73 |
| t3.large × 4 노드 (desired=1) | ~$82 |
| EBS 64GB × 4 | ~$25 |
| ALB | ~$16-20 |
| **합계** | **~$196-200** |

---

## Cleanup

```bash
# 워크로드 먼저 삭제
kubectl delete all --all -n <namespace>

# Terraform 리소스 삭제
terraform destroy
```
