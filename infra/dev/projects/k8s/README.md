# CMS EKS Cluster - Terraform Infrastructure

CMS 서비스를 위한 전용 EKS 클러스터를 Terraform으로 프로비저닝합니다.

## 📋 Overview

- **Cluster Name**: `eks-dev-cms-k8s` (auto-generated from common module)
- **Kubernetes Version**: 1.34
- **Node Type**: t3.large (1-3 nodes)
- **Service CIDR**: 10.200.0.0/16
- **Network**: vpc-276cc74c (기존 VPC, K8s 서브넷 3개)

## 📁 File Structure

```
cms-k8s/
├── terraform.tf          # Providers (AWS, Kubernetes, Helm) & S3 backend
├── variables.tf          # Variable definitions
├── data.tf               # Data sources (VPC, subnets, add-ons, ECR, ACM, Route53)
├── locals.tf             # Common module & tags
├── iam-cluster.tf        # EKS cluster IAM role
├── iam-node.tf           # Node group IAM role
├── iam-irsa.tf           # IRSA for ALB Controller, EBS CSI, Cluster Autoscaler
├── security-groups.tf    # Security group rules
├── eks-cluster.tf        # EKS cluster resource
├── eks-nodegroup.tf      # Node group resource
├── eks-addons.tf         # EKS Managed Add-ons (VPC CNI, CoreDNS, kube-proxy, EBS CSI)
├── helm-addons.tf        # Helm Add-ons (Metrics Server, ALB Controller, Cluster Autoscaler)
├── outputs.tf            # Outputs & Helm release status
├── terraform.tfvars      # Configuration values
├── policies/
│   └── alb-controller-policy.json  # ALB Controller IAM policy
└── README.md             # This file
```

## 🚀 Deployment Steps

### 1. Initialize Terraform

```bash
cd /Users/youngkwang/nextpay/infra/iac-terraform/infra/dev/projects/cms-k8s

terraform init
```

### 2. Validate Configuration

```bash
terraform validate
terraform fmt -recursive
```

### 3. Plan Deployment

```bash
terraform plan -out=tfplan

# Review the plan carefully
terraform show tfplan
```

### 4. Apply Configuration

```bash
terraform apply tfplan
```

**Expected Duration**:
- EKS Cluster & Node Group: 15-20 minutes
- Helm Add-ons (auto-installed): 5 minutes
- **Total**: ~20-25 minutes

**What gets installed automatically**:
- EKS Cluster & Node Group
- EKS Managed Add-ons (VPC CNI, CoreDNS, kube-proxy, EBS CSI Driver)
- Metrics Server (Helm)
- AWS Load Balancer Controller (Helm)
- Cluster Autoscaler (Helm)

### 5. Configure kubectl

```bash
# Get command from Terraform output
terraform output -raw kubectl_config_command | bash

# Or manually:
aws eks update-kubeconfig --region ap-northeast-2 --name eks-dev-cms-k8s

# Verify cluster
kubectl get nodes
kubectl get pods -A
```

### 6. Verify Add-ons

```bash
# Check EKS managed add-ons
kubectl get daemonset -n kube-system vpc-cni
kubectl get deployment -n kube-system coredns
kubectl get daemonset -n kube-system kube-proxy
kubectl get deployment -n kube-system ebs-csi-controller

# Check Helm add-ons (auto-installed by Terraform)
kubectl get deployment -n kube-system metrics-server
kubectl get deployment -n kube-system aws-load-balancer-controller
kubectl get deployment -n kube-system cluster-autoscaler

# Test Metrics Server
kubectl top nodes
kubectl top pods -A

# Check Helm release status from Terraform
terraform output metrics_server_status
terraform output alb_controller_status
terraform output cluster_autoscaler_status
```

## 📦 What's Included

### EKS Cluster
- K8s version 1.33
- Control plane logging enabled (api, audit, authenticator, controllerManager, scheduler)
- Public & private endpoint access
- Service CIDR: 10.200.0.0/16

### Node Group
- Instance type: t3.large
- AMI: Amazon Linux 2023
- Scaling: 1-3 nodes (desired: 2)
- Disk size: 30 GB
- Capacity type: ON_DEMAND

### EKS Add-ons (Managed)
- VPC CNI (latest)
- CoreDNS (latest)
- kube-proxy (latest)
- EBS CSI Driver (latest, with IRSA)

### Add-ons (Helm, Auto-installed by Terraform)
- Metrics Server (for resource metrics)
- AWS Load Balancer Controller (with IRSA)
- Cluster Autoscaler (with IRSA)

### IAM Roles
- EKS Cluster role
- Node group role
- IRSA for ALB Controller
- IRSA for EBS CSI Driver
- IRSA for Cluster Autoscaler

## 🔍 Verification

### Check Cluster Status

```bash
# Cluster info
kubectl cluster-info
kubectl get nodes -o wide

# Check add-ons
kubectl get daemonset -n kube-system vpc-cni
kubectl get deployment -n kube-system coredns
kubectl get daemonset -n kube-system kube-proxy
kubectl get deployment -n kube-system ebs-csi-controller

# Check Metrics Server, ALB Controller & Cluster Autoscaler
kubectl get deployment -n kube-system metrics-server
kubectl get deployment -n kube-system aws-load-balancer-controller
kubectl get deployment -n kube-system cluster-autoscaler

# Test Metrics Server
kubectl top nodes
kubectl top pods -A
```

### View Terraform Outputs

```bash
terraform output
terraform output cluster_endpoint
terraform output cluster_oidc_issuer_url
```

## 🛠️ Troubleshooting

### Issue: Cluster creation fails

```bash
# Check IAM permissions
aws sts get-caller-identity

# Review Terraform plan
terraform plan

# Check AWS console for error details
```

### Issue: Node group not ready

```bash
# Check node group status
aws eks describe-nodegroup \
  --cluster-name eks-dev-cms-k8s \
  --nodegroup-name nodegroup-dev-cms-k8s \
  --region ap-northeast-2

# Check node logs
kubectl describe node <node-name>
```

### Issue: Add-on installation fails

```bash
# Check IRSA configuration
kubectl get serviceaccount -n kube-system aws-load-balancer-controller
kubectl describe serviceaccount -n kube-system aws-load-balancer-controller

# Check IAM role ARN
terraform output alb_controller_role_arn
```

## 🔐 Security Considerations

- **API Server Access**: Currently open to 0.0.0.0/0. **Restrict in production!**
- **IRSA**: Pod-level IAM permissions configured for add-ons
- **Secrets**: Store sensitive data in Kubernetes Secrets or AWS Secrets Manager
- **Network Policies**: Consider implementing Calico or Cilium
- **Pod Security**: Consider enabling Pod Security Standards

## 💰 Cost Estimate

### Monthly Costs (Seoul Region)
- **EKS Control Plane**: $73/month
- **t3.large nodes (2×)**: $121/month
- **EBS volumes (60 GB)**: $6/month
- **NAT Gateway**: $0 (reusing existing)
- **ALB**: $16-20/month
- **Total**: ~$216-220/month

## 🗑️ Cleanup

**⚠️ WARNING: This will destroy all EKS resources!**

```bash
# First, delete all workloads running on the cluster
kubectl delete all --all -n dev-cms

# Then destroy Terraform resources
terraform destroy

# Confirm destruction
```

## 📚 Next Steps

### Deploy CMS Application

Create Helm chart or Kubernetes manifests for:
- Namespace: `dev-cms`
- ConfigMap: Non-sensitive environment variables
- Secret: Sensitive credentials
- Deployment: CMS main (port 3827)
- Deployment: CMS cron (CRON=ENABLE)
- Service: ClusterIP
- Ingress: ALB Ingress (dev-cms.nextpay.co.kr)
- HPA: CPU 70%, Memory 80%

### Set Up Monitoring

- Install Prometheus & Grafana
- Configure CloudWatch Container Insights
- Set up alerting rules

### Configure CI/CD

- GitHub Actions for image builds
- ArgoCD or Flux for GitOps deployment
- Automated testing pipeline

## 📖 References

- [AWS EKS Best Practices](https://aws.github.io/aws-eks-best-practices/)
- [AWS Load Balancer Controller](https://kubernetes-sigs.github.io/aws-load-balancer-controller/)
- [Cluster Autoscaler](https://github.com/kubernetes/autoscaler/tree/master/cluster-autoscaler)
- [Plan Document](/Users/youngkwang/.claude/plans/greedy-baking-babbage.md)

## 🆘 Support

For issues or questions:
1. Check Terraform plan output
2. Review CloudWatch logs
3. Check EKS console for error details
4. Review plan document for migration strategy
