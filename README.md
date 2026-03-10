# ⚡ VitalAxis - Personal Life Optimization Dashboard

![AWS](https://img.shields.io/badge/AWS-FF9900?style=for-the-badge&logo=amazonaws&logoColor=white)
![Terraform](https://img.shields.io/badge/Terraform-7B42BC?style=for-the-badge&logo=terraform&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)
![GitHub Actions](https://img.shields.io/badge/GitHub_Actions-2088FF?style=for-the-badge&logo=github-actions&logoColor=white)
![Flask](https://img.shields.io/badge/Flask-000000?style=for-the-badge&logo=flask&logoColor=white)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-316192?style=for-the-badge&logo=postgresql&logoColor=white)

---

## **Project Overview**

VitalAxis is a production-ready, scalable **3-tier web application** deployed on AWS. It helps users optimize their daily lives by tracking time, managing budgets, and setting personal goals - all in one place.

### **Features**

| Module | Description |
|--------|-------------|
| ⏰ **Time Tracker** | Log daily activities and visualize time distribution |
| 💰 **Budget Manager** | Track income/expenses with category breakdowns |
| 🎯 **Goal Setting** | Set and monitor progress towards personal goals |
| 📊 **Dashboard** | Real-time insights and productivity analytics |

---

## **Architecture**



### **AWS Resources Created**
- ✅ **VPC** with CIDR 10.0.0.0/16 (Multi-AZ)
- ✅ **2 Public Subnets**: 10.0.1.0/24, 10.0.2.0/24
- ✅ **2 Private Subnets**: 10.0.3.0/24, 10.0.4.0/24
- ✅ **Internet Gateway** for public internet access
- ✅ **NAT Gateway** for outbound internet from private subnets
- ✅ **Application Load Balancer** (HTTP listener on port 80)
- ✅ **Target Group** on port 5000 with /health check
- ✅ **Auto Scaling Group** (min:1, max:4, desired:2)
- ✅ **Launch Template** with user_data for Docker setup
- ✅ **EC2 instances** (t3.micro) running Docker containers
- ✅ **RDS PostgreSQL** (db.t3.micro, encrypted, backup retention 1 day)
- ✅ **Security Groups** (ALB, EC2, RDS) with least privilege
- ✅ **IAM Roles** with SSM, CloudWatch, and Parameter Store access
- ✅ **CloudWatch** Logs, Metrics, and Alarms
- ✅ **CloudWatch Dashboard** for visualization

---

## 🛠️ **Tech Stack**

| Layer | Technology |
|-------|------------|
| **Frontend** | HTML5, CSS3, JavaScript, Bootstrap 5 |
| **Backend** | Python 3.9, Flask 2.3, Gunicorn 21.2 |
| **Database** | PostgreSQL 15.15 with SQLAlchemy 2.0 ORM |
| **Container** | Docker, Docker Compose |
| **Infrastructure** | Terraform 1.0+ (AWS Provider) |
| **CI/CD** | GitHub Actions |
| **Monitoring** | AWS CloudWatch Logs, Metrics, Alarms |
| **Secrets** | AWS Systems Manager Parameter Store |

---

## 📁 **Project Structure**
VitalAxis/
├── .github/
│ └── workflows/
│ └── deploy.yml # CI/CD pipeline
├── terraform/
│ ├── main.tf # Main infrastructure
│ ├── variables.tf # Variables
│ ├── outputs.tf # Outputs
│ ├── terraform.tfvars.example # Variable template
│ ├── user_data.sh # EC2 bootstrap script
│ ├── cloudwatch_logs.tf # CloudWatch configuration
│ ├── dashboard.tf # CloudWatch dashboard
│ ├── parameter_store.tf # SSM Parameter Store
│ └── security_update.tf # Security group rules
├── app/
│ ├── init.py
│ ├── models.py # Database models
│ └── templates/ # HTML templates
│ ├── base.html
│ ├── index.html
│ ├── dashboard.html
│ ├── time.html
│ └── budget.html
├── ec2-config/
│ ├── docker-compose.yml # EC2 container config
│ └── .env.template # Environment variables template
├── main.py # Flask application
├── wsgi.py # Gunicorn entry point
├── Dockerfile # Container definition
├── requirements.txt # Python dependencies
├── .gitignore # Git ignore rules
└── README.md # This file

---

## 🚀 **Deployment Instructions**

### **Prerequisites**
- [AWS Account](https://aws.amazon.com/free/) with appropriate permissions
- [Docker Hub](https://hub.docker.com/) account
- [GitHub](https://github.com) account
- [Terraform](https://www.terraform.io/downloads) installed locally (v1.0+)
- [AWS CLI](https://aws.amazon.com/cli/) configured
- [Git](https://git-scm.com/) installed

### **Step 1: Clone the Repository**
```bash
git clone https://github.com/Trapholo01/VitalAxis.git
cd VitalAxis

### **Step 2: Configure Terraform Variables** 
```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values
nano terraform.tfvars

### **Step 3: Deploy Infrastructure**
```bash
terraform init
terraform plan
terraform apply
# Type 'yes' when prompted

### **Step 4: Set GitHub Secrets**
Go to **Settings** → **Secrets and variables** → **Actions** and add:

| Secret Name	| Value |
|--------|-------------|
| DOCKER_USERNAME	| Your Docker Hub username |
| DOCKER_PASSWORD |	Your Docker Hub password |
| AWS_ACCESS_KEY_ID |	Your AWS access key |
| AWS_SECRET_ACCESS_KEY	| Your AWS secret key |
| EC2_SSH_KEY | Content of vitalaxis-ssh-key |
| RDS_ENDPOINT	| Output from terraform output rds_endpoint |

### **Step 5: Deploy Application**
```bash
# Make a change and push to trigger CI/CD
git add .
git commit -m "Initial deployment"
git push origin main

### **Step 6: Access Your Application**
```bash
# Get the ALB endpoint
cd terraform
terraform output alb_dns_name
# Open in browser: http://[alb-dns-name]

---

📊 Monitoring & Observability
CloudWatch Logs
Log Group: /vitalaxis/application

Retention: 7 days

Log Streams:

syslog-[instance-id]

docker-[hostname]

View logs:

bash
aws logs describe-log-streams --log-group-name /vitalaxis/application
aws logs get-log-events --log-group-name /vitalaxis/application --log-stream-name [stream-name]
CloudWatch Dashboard
Name: vitalaxis-dashboard

Widgets:

EC2 CPU Utilization

Recent Application Logs

Memory & Disk Usage

ALB Request Count

CloudWatch Alarms
Alarm Name	Metric	Threshold	Action
vitalaxis-cpu-high	CPUUtilization	>70% for 2 mins	Scale Up (+1 instance)
vitalaxis-cpu-low	CPUUtilization	<30% for 2 mins	Scale Down (-1 instance)
vitalaxis-high-error-rate	ErrorCount	>10 errors in 5 mins	SNS Alert
🔒 Security Implementation
Network Security
✅ EC2 instances in private subnets (no direct internet access)

✅ RDS in private subnets (no public access)

✅ NAT Gateway for outbound internet (updates, Docker pulls)

✅ Security Groups with least privilege access

Security Group Rules
Security Group	Inbound Rules	Outbound Rules
ALB	HTTP (80) from 0.0.0.0/0	All traffic
EC2	SSH (22) from 102.212.63.248/32 (My IP)
Flask (5000) from ALB SG	All traffic
RDS	PostgreSQL (5432) from EC2 SG	None
IAM Security
✅ IAM Roles instead of access keys on EC2

✅ Least privilege policies for each service

✅ AWS Systems Manager for secure instance access

✅ Parameter Store for secrets management

Data Security
✅ RDS Encryption at rest

✅ SSL/TLS for database connections

✅ No hardcoded secrets in code

✅ Environment variables for configuration

📈 Auto Scaling Configuration
hcl
# Auto Scaling Group
resource "aws_autoscaling_group" "main" {
  min_size             = 1
  max_size             = 4
  desired_capacity     = 2
  health_check_type    = "ELB"
  vpc_zone_identifier  = aws_subnet.private[*].id
  
  # Scaling Policies
  scale_up_policy   = add 1 instance when CPU > 70%
  scale_down_policy = remove 1 instance when CPU < 30%
  cooldown_period   = 300 seconds
}
Scaling Events
Load increases → CPU >70% for 2 minutes

CloudWatch alarm triggers

Auto Scaling adds new instance

New instance registers with ALB

Load distributes across instances

When load drops → instances scale down

💰 Cost Estimation
AWS Free Tier Usage
All resources within AWS Free Tier limits:

EC2 t3.micro: 750 hours/month ✅

RDS db.t3.micro: 750 hours/month ✅

ALB: 750 hours/month ✅

CloudWatch: 10 metrics, 5GB logs ✅

Data Transfer: 15GB outbound ✅

Monthly Cost (Beyond Free Tier)
Resource	Quantity	Monthly Cost
EC2 t3.micro (2 instances)	2 × 730 hrs	$24.82
RDS db.t3.micro	1 × 730 hrs	$15.00
Application Load Balancer	1 × 730 hrs	$18.25
NAT Gateway	1 × 730 hrs	$32.40
Data Transfer (100GB)	100 GB	$9.00
EBS Storage (60GB)	60 GB	$6.00
Elastic IP	1	$3.65
TOTAL		~$109.12/month
Cost Optimization Tips
Use Spot Instances for non-production (save up to 70%)

Scale to 0 instances during off-hours

Enable Compute Savings Plans (save up to 30%)

Use RDS Reserved Instances (1-year, save up to 30%)

Set up AWS Budget Alerts at $5/month

🧪 Local Development
Run with Python (Virtual Environment)
bash
# Create virtual environment
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Run the app
python main.py
Run with Docker
bash
# Build image
docker build -t vitalaxis:latest .

# Run container
docker run -p 5000:5000 vitalaxis:latest
Run with Docker Compose
bash
docker-compose up --build
Access Locally
text
http://localhost:5000
🔍 API Endpoints
Endpoint	Method	Description
/	GET	Landing page
/dashboard	GET	User dashboard
/time	GET	Time tracking interface
/budget	GET	Budget management
/health	GET	Health check for ALB
/api/time	POST	Create time entry
/api/transactions	POST	Add transaction
/api/goals	POST	Create new goal
🌐 Live Application
ALB Endpoint:

text
http://vitalaxis-alb-121674140.af-south-1.elb.amazonaws.com
📸 Screenshots
Infrastructure
VPC Configuration	[Add screenshot]
EC2 Instances	[Add screenshot]
RDS Database	[Add screenshot]
Load Balancer	[Add screenshot]
Auto Scaling Group	[Add screenshot]
Monitoring
CloudWatch Dashboard	[Add screenshot]
CloudWatch Logs	[Add screenshot]
CloudWatch Alarms	[Add screenshot]
Application
Landing Page	[Add screenshot]
Dashboard	[Add screenshot]
Time Tracker	[Add screenshot]
Budget Manager	[Add screenshot]
CI/CD
GitHub Actions Pipeline	[Add screenshot]
Successful Deployment	[Add screenshot]
🏆 Key Achievements
✅ Complete 3-tier architecture on AWS with Terraform

✅ Production-ready Flask application with PostgreSQL

✅ Docker containerization with CloudWatch logging

✅ CI/CD pipeline with GitHub Actions

✅ Auto-scaling based on CPU metrics (min:1, max:4)

✅ CloudWatch monitoring with custom dashboard

✅ Security best practices (least privilege, encryption, private subnets)

✅ Infrastructure as Code (version-controlled)

✅ AWS Free Tier compliant (cost optimized)

✅ Comprehensive documentation

🚧 Future Enhancements
HTTPS with ACM certificates

Custom domain with Route 53

Blue/Green deployments for zero downtime

Prometheus + Grafana for advanced monitoring

Mobile app with AWS Amplify

Database read replicas for scaling

Caching with ElastiCache (Redis)

User authentication with Cognito

CI/CD notifications with SNS

Infrastructure testing with Terratest

🐛 Troubleshooting
Common Issues
Issue	Solution
SSH timeout	Instance is in private subnet - use Session Manager
RDS connection failed	Check security group rules (EC2 → RDS)
Container not starting	Check logs: docker logs vitalaxis-app
CloudWatch no logs	Verify IAM role and agent status
ALB 503 errors	Check target group health checks
Terraform apply fails	Run terraform plan to see errors
📚 Documentation
Terraform Configuration

CI/CD Pipeline

API Documentation

Contributing Guidelines

📝 License
This project is part of a cloud engineering portfolio. All rights reserved.

👨‍💻 Author
Thato Rapholo

GitHub: @Trapholo01

Project: VitalAxis

LinkedIn: [Add your LinkedIn]

🙏 Acknowledgments
AWS Free Tier for enabling this project

HashiCorp for Terraform documentation

Flask and PostgreSQL communities

GitHub Actions for CI/CD

Docker for containerization

Cloud Engineering Project Brief for guidance

📊 Project Status
Completed: March 2026
Version: 1.0.0
Status: Production Ready 🚀

⭐ Support
If you find this project useful, please consider:
⭐ Starring the repository on GitHub
📢 Sharing with others
🐛 Reporting issues
🤝 Contributing improvements

Made with ❤️ and ☁️ AWS
