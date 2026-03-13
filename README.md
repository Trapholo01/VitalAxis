# ⚡ VitalAxis — Personal Life Optimization Dashboard

![AWS](https://img.shields.io/badge/AWS-FF9900?style=for-the-badge&logo=amazonaws&logoColor=white)
![Terraform](https://img.shields.io/badge/Terraform-7B42BC?style=for-the-badge&logo=terraform&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)
![GitHub Actions](https://img.shields.io/badge/GitHub_Actions-2088FF?style=for-the-badge&logo=github-actions&logoColor=white)
![Flask](https://img.shields.io/badge/Flask-000000?style=for-the-badge&logo=flask&logoColor=white)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-316192?style=for-the-badge&logo=postgresql&logoColor=white)

> A production-ready, scalable **3-tier web application** deployed on AWS that helps users optimize their daily lives by tracking time, managing budgets, and setting personal goals — all in one place.

---

## Table of Contents

- [Features](#-features)
- [Architecture](#️-architecture)
- [Tech Stack](#️-tech-stack)
- [Project Structure](#-project-structure)
- [Deployment Instructions](#-deployment-instructions)
- [Monitoring & Observability](#-monitoring--observability)
- [Security](#-security-implementation)
- [Auto Scaling](#-auto-scaling-configuration)
- [Cost Estimation](#-cost-estimation)
- [Local Development](#-local-development)
- [API Endpoints](#-api-endpoints)
- [Troubleshooting](#-troubleshooting)

---

## Features

| Module | Description |
|--------|-------------|
|  **Time Tracker** | Log daily activities and visualize time distribution |
|  **Budget Manager** | Track income/expenses with category breakdowns |
|  **Goal Setting** | Set and monitor progress towards personal goals |
|  **Dashboard** | Real-time insights and productivity analytics |

---

## Architecture

### AWS Resources

| Resource | Details |
|----------|---------|
| **VPC** | CIDR 10.0.0.0/16 (Multi-AZ) |
| **Public Subnets** | 10.0.1.0/24, 10.0.2.0/24 |
| **Private Subnets** | 10.0.3.0/24, 10.0.4.0/24 |
| **Internet Gateway** | Public internet access |
| **NAT Gateway** | Outbound internet from private subnets |
| **Application Load Balancer** | HTTP listener on port 80 |
| **Target Group** | Port 5000 with `/health` check |
| **Auto Scaling Group** | min: 1 · max: 4 · desired: 2 |
| **EC2 Instances** | t3.micro running Docker containers |
| **RDS PostgreSQL** | db.t3.micro, encrypted, 1-day backup retention |
| **Security Groups** | ALB, EC2, RDS — least privilege |
| **IAM Roles** | SSM, CloudWatch, and Parameter Store access |
| **CloudWatch** | Logs, Metrics, Alarms, and Dashboard |

---

## Tech Stack

| Layer | Technology |
|-------|------------|
| **Frontend** | HTML5, CSS3, JavaScript, Bootstrap 5 |
| **Backend** | Python 3.9, Flask 2.3, Gunicorn 21.2 |
| **Database** | PostgreSQL 15 with SQLAlchemy 2.0 ORM |
| **Container** | Docker, Docker Compose |
| **Infrastructure** | Terraform 1.0+ (AWS Provider) |
| **CI/CD** | GitHub Actions |
| **Monitoring** | AWS CloudWatch (Logs, Metrics, Alarms) |
| **Secrets** | AWS Systems Manager Parameter Store |

---

## Project Structure

```
VitalAxis/
├── .github/
│   └── workflows/
│       └── deploy.yml          # CI/CD pipeline
├── terraform/
│   ├── main.tf                 # Main infrastructure
│   ├── variables.tf            # Variables
│   ├── outputs.tf              # Outputs
│   ├── terraform.tfvars.example
│   ├── user_data.sh            # EC2 bootstrap script
│   ├── cloudwatch_logs.tf
│   ├── dashboard.tf
│   ├── parameter_store.tf
│   └── security_update.tf
├── app/
│   ├── __init__.py
│   ├── models.py               # Database models
│   └── templates/
│       ├── base.html
│       ├── index.html
│       ├── dashboard.html
│       ├── time.html
│       └── budget.html
├── ec2-config/
│   ├── docker-compose.yml
│   └── .env.template
├── main.py                     # Flask application
├── wsgi.py                     # Gunicorn entry point
├── Dockerfile
├── requirements.txt
└── README.md
```

---

## Deployment Instructions

### Prerequisites

- [AWS Account](https://aws.amazon.com/free/) with appropriate permissions
- [Docker Hub](https://hub.docker.com/) account
- [GitHub](https://github.com) account
- [Terraform](https://www.terraform.io/downloads) v1.0+ installed locally
- [AWS CLI](https://aws.amazon.com/cli/) configured
- [Git](https://git-scm.com/) installed

---

### Step 1: Clone the Repository

```bash
git clone https://github.com/Trapholo01/VitalAxis.git
cd VitalAxis
```

### Step 2: Configure Terraform Variables

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
nano terraform.tfvars   # Edit with your values
```

### Step 3: Deploy Infrastructure

```bash
terraform init
terraform plan
terraform apply   # Type 'yes' when prompted
```

### Step 4: Set GitHub Secrets

Go to **Settings → Secrets and variables → Actions** and add:

| Secret Name | Value |
|-------------|-------|
| `DOCKER_USERNAME` | Your Docker Hub username |
| `DOCKER_PASSWORD` | Your Docker Hub password |
| `AWS_ACCESS_KEY_ID` | Your AWS access key |
| `AWS_SECRET_ACCESS_KEY` | Your AWS secret key |
| `EC2_SSH_KEY` | Content of `vitalaxis-ssh-key` |
| `RDS_ENDPOINT` | Output from `terraform output rds_endpoint` |

### Step 5: Trigger Deployment

```bash
git add .
git commit -m "Initial deployment"
git push origin main
```

### Step 6: Access the Application

```bash
cd terraform
terraform output alb_dns_name
# Open in browser: http://[alb-dns-name]
```

---

## Monitoring & Observability

### CloudWatch Logs

- **Log Group:** `/vitalaxis/application`
- **Retention:** 7 days
- **Log Streams:** `syslog-[instance-id]`, `docker-[hostname]`

```bash
# View log streams
aws logs describe-log-streams --log-group-name /vitalaxis/application

# Read log events
aws logs get-log-events \
  --log-group-name /vitalaxis/application \
  --log-stream-name [stream-name]
```

### CloudWatch Dashboard

**Name:** `vitalaxis-dashboard`

Widgets included:
- EC2 CPU Utilization
- Recent Application Logs
- Memory & Disk Usage
- ALB Request Count

### CloudWatch Alarms

| Alarm | Metric | Threshold | Action |
|-------|--------|-----------|--------|
| `vitalaxis-cpu-high` | CPUUtilization | >70% for 2 min | Scale up (+1 instance) |
| `vitalaxis-cpu-low` | CPUUtilization | <30% for 2 min | Scale down (-1 instance) |
| `vitalaxis-high-error-rate` | ErrorCount | >10 errors in 5 min | SNS Alert |

---

## Security Implementation

### Network Security

- ✅ EC2 instances in **private subnets** (no direct internet access)
- ✅ RDS in **private subnets** (no public access)
- ✅ **NAT Gateway** for outbound traffic (updates, Docker pulls)
- ✅ **Security Groups** with least privilege access

### Security Group Rules

| Security Group | Inbound | Outbound |
|----------------|---------|----------|
| ALB | HTTP (80) from `0.0.0.0/0` | All traffic |
| EC2 | SSH (22) from my IP · Flask (5000) from ALB SG | All traffic |
| RDS | PostgreSQL (5432) from EC2 SG | None |

### IAM & Data Security

- ✅ IAM Roles instead of access keys on EC2
- ✅ Least privilege policies per service
- ✅ AWS Systems Manager for secure instance access
- ✅ Parameter Store for secrets management
- ✅ RDS encryption at rest
- ✅ SSL/TLS for database connections
- ✅ No hardcoded secrets in code

---

## Auto Scaling Configuration

```hcl
resource "aws_autoscaling_group" "main" {
  min_size             = 1
  max_size             = 4
  desired_capacity     = 2
  health_check_type    = "ELB"
  vpc_zone_identifier  = aws_subnet.private[*].id
}
```

**Scaling flow:**

1. Load increases → CPU >70% for 2 minutes
2. CloudWatch alarm triggers scaling policy
3. Auto Scaling launches a new instance
4. New instance registers with the ALB
5. Load distributes across all healthy instances
6. Load drops → instances scale down automatically

**Cooldown period:** 300 seconds between scaling events

---

## Cost Estimation

### AWS Free Tier Coverage

| Resource | Free Tier Limit |
|----------|-----------------|
| EC2 t3.micro | 750 hrs/month ✅ |
| RDS db.t3.micro | 750 hrs/month ✅ |
| ALB | 750 hrs/month ✅ |
| CloudWatch | 10 metrics · 5 GB logs ✅ |
| Data Transfer | 15 GB outbound ✅ |

### Estimated Monthly Cost (Beyond Free Tier)

| Resource | Qty | Monthly Cost |
|----------|-----|-------------|
| EC2 t3.micro (2 instances) | 2 × 730 hrs | $24.82 |
| RDS db.t3.micro | 1 × 730 hrs | $15.00 |
| Application Load Balancer | 1 × 730 hrs | $18.25 |
| NAT Gateway | 1 × 730 hrs | $32.40 |
| Data Transfer (100 GB) | 100 GB | $9.00 |
| EBS Storage (60 GB) | 60 GB | $6.00 |
| Elastic IP | 1 | $3.65 |
| **Total** | | **~$109.12/month** |

### Cost Optimization Tips

- Use **Spot Instances** for non-production (save up to 70%)
- **Scale to 0** instances during off-hours
- Enable **Compute Savings Plans** (save up to 30%)
- Use **RDS Reserved Instances** — 1-year (save up to 30%)
- Set up **AWS Budget Alerts** at $5/month threshold

---

## Local Development

### Option 1: Python Virtual Environment

```bash
python -m venv venv
source venv/bin/activate        # Windows: venv\Scripts\activate
pip install -r requirements.txt
python main.py
```

### Option 2: Docker

```bash
docker build -t vitalaxis:latest .
docker run -p 5000:5000 vitalaxis:latest
```

### Option 3: Docker Compose

```bash
docker-compose up --build
```

Access locally at: `http://localhost:5000`

---

## API Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/` | GET | Landing page |
| `/dashboard` | GET | User dashboard |
| `/time` | GET | Time tracking interface |
| `/budget` | GET | Budget management |
| `/health` | GET | Health check for ALB |
| `/api/time` | POST | Create time entry |
| `/api/transactions` | POST | Add transaction |
| `/api/goals` | POST | Create new goal |

---

## Live Application

```
http://vitalaxis-alb-121674140.af-south-1.elb.amazonaws.com
```

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| SSH timeout | Instance is in private subnet — use Session Manager |
| RDS connection failed | Check security group rules (EC2 → RDS on port 5432) |
| Container not starting | `docker logs vitalaxis-app` |
| CloudWatch no logs | Verify IAM role and CloudWatch agent status |
| ALB 503 errors | Check target group health checks |
| `terraform apply` fails | Run `terraform plan` to inspect errors |

---

## Key Achievements

- ✅ Complete 3-tier architecture on AWS provisioned with Terraform
- ✅ Production-ready Flask application backed by PostgreSQL
- ✅ Docker containerization with integrated CloudWatch logging
- ✅ CI/CD pipeline via GitHub Actions
- ✅ Auto Scaling based on CPU metrics (min: 1 · max: 4)
- ✅ CloudWatch monitoring with custom dashboard and alarms
- ✅ Security best practices: least privilege, encryption, private subnets
- ✅ Fully version-controlled Infrastructure as Code
- ✅ AWS Free Tier compliant and cost optimized

---

## Future Enhancements

- [ ] HTTPS with ACM certificates
- [ ] Custom domain with Route 53
- [ ] Blue/Green deployments for zero downtime
- [ ] Prometheus + Grafana for advanced monitoring
- [ ] Mobile app with AWS Amplify
- [ ] Database read replicas for horizontal scaling
- [ ] Caching layer with ElastiCache (Redis)
- [ ] User authentication with Amazon Cognito
- [ ] CI/CD notifications with SNS
- [ ] Infrastructure testing with Terratest

---

## Author

**Thato Rapholo**

- GitHub: [@Trapholo01](https://github.com/Trapholo01)
- LinkedIn: *[Add your LinkedIn]*

---

## License

This project is part of a cloud engineering portfolio. All rights reserved.

---

## Acknowledgments

- [AWS Free Tier](https://aws.amazon.com/free/) for enabling this project
- [HashiCorp Terraform](https://developer.hashicorp.com/terraform/docs) documentation
- Flask and PostgreSQL open-source communities
- GitHub Actions for CI/CD infrastructure
- Docker for containerization tooling

---

<div align="center">

**📊 Project Status:** Completed March 2026 · v1.0.0 · 🚀 Production Ready

*Made with ❤️ and ☁️ AWS*

⭐ If you find this project useful, please consider starring the repo!

</div>
