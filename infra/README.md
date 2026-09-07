# Infrastructure — Python Calculator App

Terraform configuration for a single-node RKE2 Kubernetes cluster on AWS EC2,
fronted by an Application Load Balancer (ALB), with an ECR repository for
container images.

## Architecture

```
Internet
   │
   ▼
 ALB (HTTP :80)          ← aws_lb.main  (calculator-alb)
   │
   ▼
EC2 t3.medium            ← aws_instance.rke2  (calculator-rke2-node)
  NodePort :30080
  running RKE2 (single-node k8s)
   │
   ▼
ECR calculator-app       ← aws_ecr_repository.calculator
```

### Networking

| Resource | CIDR / value |
|---|---|
| VPC | `10.0.0.0/16` |
| Public subnet | `10.0.1.0/24` (us-east-1a) |
| ALB SG | inbound TCP 80 from `0.0.0.0/0` |
| EC2 SG | inbound TCP 30080 from ALB SG; TCP 22 from `0.0.0.0/0` |

## Prerequisites

1. **AWS credentials** — either `AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY`
   environment variables, or an AWS profile configured in `~/.aws/credentials`.
2. **Terraform ≥ 1.6.0** — `brew install terraform` or via [tfenv](https://github.com/tfutils/tfenv).
3. **Bootstrap the S3 backend** (once, before the first `terraform init`):

   ```bash
   chmod +x infra/bootstrap.sh
   ./infra/bootstrap.sh
   ```

   This creates:
   - S3 bucket `udap-calculator-tf-state-a7f3k9` (versioned, encrypted, public-access blocked)
   - DynamoDB table `udap-calculator-tf-lock` (PAY_PER_REQUEST, LockID PK)

## Local usage

```bash
cd infra

# One-time backend bootstrap (skip if bucket/table already exist)
../infra/bootstrap.sh

# Initialise
terraform init

# Review the plan
terraform plan

# Apply
terraform apply

# Outputs
terraform output ec2_public_ip
terraform output alb_dns_name
terraform output ecr_repository_url
```

## GitHub Actions

The workflow at `.github/workflows/infra.yml` runs automatically on every push
to `main` that touches `infra/**`.

### Required secrets (set in GitHub → Settings → Secrets and variables → Actions)

| Secret | Description |
|---|---|
| `AWS_ACCESS_KEY_ID` | IAM user access key with EC2/ECR/ALB/IAM permissions |
| `AWS_SECRET_ACCESS_KEY` | Corresponding secret key |
| `AWS_REGION` | Optional — defaults to `us-east-1` |

After a successful apply the workflow writes three repository variables:

| Variable | Contains |
|---|---|
| `TF_OUT_ALB_DNS_NAME` | ALB DNS name — the app's HTTP endpoint |
| `TF_OUT_ECR_REPOSITORY_URL` | Full ECR URL for `docker push` |
| `TF_OUT_EC2_PUBLIC_IP` | EC2 public IP (for SSH / kubeconfig) |

These variables are consumed by the application deploy workflow (Session 3).

## Outputs

| Output | Description |
|---|---|
| `ec2_public_ip` | Public IP of the RKE2 node |
| `alb_dns_name` | ALB DNS name (HTTP endpoint) |
| `ecr_repository_url` | ECR image URL for `calculator-app` |
| `vpc_id` | VPC ID |
| `public_subnet_id` | Subnet ID |
| `alb_arn` | ALB ARN |
| `target_group_arn` | Target group ARN (HTTP:30080) |

## RKE2 bootstrap

The EC2 user-data script (`user_data.sh.tpl`) does the following at first boot:

1. Fetches the instance public IP from EC2 Instance Metadata Service (IMDSv2).
2. Writes `/etc/rancher/rke2/config.yaml` with `node-external-ip` and `tls-san`.
3. Installs RKE2 server via `curl -sfL https://get.rke2.io | sh -`.
4. Enables and starts `rke2-server.service`.
5. Adds `/var/lib/rancher/rke2/bin` to PATH and symlinks `kubectl`.
6. Waits up to 10 minutes for the node to reach `Ready`.

Logs are written to `/var/log/user-data.log`.

## Accessing the cluster

```bash
# SSH into the node
ssh -i ~/.ssh/<key>.pem ec2-user@<ec2_public_ip>

# Copy the kubeconfig
scp ec2-user@<ec2_public_ip>:/etc/rancher/rke2/rke2.yaml ~/.kube/calculator-rke2.yaml
# Edit server address from 127.0.0.1 to <ec2_public_ip>
sed -i "s/127.0.0.1/<ec2_public_ip>/g" ~/.kube/calculator-rke2.yaml
export KUBECONFIG=~/.kube/calculator-rke2.yaml
kubectl get nodes
```
