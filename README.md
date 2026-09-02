# devops-demo-api — CI/CD Pipeline to AWS ECS Fargate

A production-style CI/CD pipeline deploying a containerized FastAPI service to
AWS using Terraform, GitHub Actions, and blue/green deployments via
CodeDeploy. Built as a portfolio project to demonstrate real-world DevOps
practices, not just "docker push."

## Architecture
GitHub PR ──► CI (lint, test, SAST, Trivy scan) ──► push image to ECR
                                                            │
                                                            ▼
                                      CD: register new ECS task definition
                                                            │
                                                            ▼
                                CodeDeploy blue/green (canary 10% / 5 min)
                                        │                         │
                                   blue target group        green target group
                                        └──────────► ALB ◄────────┘
                                                     │
                                            ECS Fargate service
                                            (private subnets, 2 AZs)
```
 
Infra is provisioned by Terraform: VPC (public + private subnets across 2
AZs, NAT gateway), ECR repo, ECS cluster + Fargate service, ALB with two
target groups (blue/green), CodeDeploy app + deployment group, and IAM roles
— including a GitHub OIDC role so CI never uses long-lived AWS access keys.

## Why these choices

- **ECS Fargate** over EKS: no cluster/node management, still demonstrates
  container orchestration, ALB integration, and IAM task roles — without
  burning a week debugging Kubernetes networking.
- **Blue/green via CodeDeploy** instead of a rolling ECS update: shows an
  understanding of progressive delivery and automatic rollback on failed
  health checks, which is what separates "I can run docker" from "I can ship
  safely."
- **OIDC instead of IAM access keys** in GitHub Actions: no static secrets
  sitting in repo settings — a real security consideration, and a good
  interview talking point.
- **Trivy + Semgrep in CI**: the build fails on CRITICAL/HIGH vulnerabilities
  before an image ever reaches ECR.

## Repo layout

```
app/                  FastAPI service (source, tests, Dockerfile)
terraform/            All AWS infrastructure as code
ecs/                  ECS task definition + CodeDeploy appspec templates
.github/workflows/    ci.yml, cd.yml, terraform.yml
```

## One-time setup

1. **Bootstrap remote state** (do this once, manually or with a tiny script):
   ```bash
   aws s3 mb s3://YOUR-terraform-state-bucket --region eu-west-1
   aws dynamodb create-table \
     --table-name YOUR-terraform-locks \
     --attribute-definitions AttributeName=LockID,AttributeType=S \
     --key-schema AttributeName=LockID,KeyType=HASH \
     --billing-mode PAY_PER_REQUEST
   ```
   Update the bucket/table names in `terraform/provider.tf`.

2. **Edit `terraform/iam.tf`**: replace `ORG/REPO` in the GitHub OIDC trust
   policy with your actual GitHub org/repo.

3. **Provision infrastructure**:
   ```bash
   cd terraform
   terraform init
   terraform apply
   ```
   Note the `github_actions_role_arn` output.

4. **Configure GitHub repo**:
   - Settings → Secrets and variables → Actions → *Variables*:
     add `AWS_ROLE_ARN` = the role ARN from the step above.
   - Settings → Secrets → add `SLACK_WEBHOOK_URL` (optional, for deploy
     notifications).
   - Settings → Environments → create `production` and require a reviewer
     if you want manual approval before `terraform apply` on merges to main.

5. **Push to `main`** — CI builds/scans/pushes the image, then CD registers
   a new task definition and triggers a CodeDeploy blue/green rollout.

## Running locally

```bash
cd app
pip install -r requirements-dev.txt
uvicorn main:app --reload
# http://localhost:8000/health
```

```bash
docker build -t devops-demo-api ./app
docker run -p 8000:8000 devops-demo-api
```

## What this project demonstrates (CV bullets)

- Built a CI/CD pipeline (GitHub Actions) deploying a containerized FastAPI
  service to AWS ECS Fargate, with automated linting, testing, SAST, and
  container vulnerability scanning gating every merge.
- Provisioned AWS infrastructure (VPC, ECS, ALB, IAM) with Terraform using
  remote state and a PR-based plan/apply workflow.
- Implemented blue/green deployments via AWS CodeDeploy with automatic
  rollback on failed health checks, eliminating manual rollback steps.
- Replaced static AWS credentials in CI with GitHub OIDC federation,
  removing long-lived secrets from the pipeline.

## Possible extensions

- Add RDS (Postgres) and a task role scoped to read/write that specific DB.
- Add autoscaling policies on the ECS service (target tracking on CPU).
- Swap the in-memory smoke test for a small k6/Locust load test post-deploy.
- Add a `staging` environment with its own Terraform workspace.
