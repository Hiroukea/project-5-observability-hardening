 Project — Production Observability & Rollback Hardening (AWS)

Overview of this project
This project adds production-grade monitoring, alerting, and rollback safety** to an existing AWS application stack.  
The goal is to demonstrate operational readiness, not just infrastructure creation.

The solution focuses on:
- Detecting real failures
- Alerting engineers immediately
- Enabling fast, safe rollback without redeploying infrastructure

Architecture
Existing workloads hardened in this project:
- Application Load Balancer (ALB)
- EC2 Auto Scaling application (Project 1)
- Serverless order processing (AWS Lambda + DynamoDB)
- Infrastructure managed via Terraform (from previous projects)

Services used in this project:
- Amazon CloudWatch
- Amazon SNS
- AWS Lambda (versioning + aliases)
- AWS CLI
- PowerShell

This Project Implements:

1. Monitoring & Alerts
CloudWatch alarms were created to monitor user-impacting failures

- ALB 5XX Errors
  - Detects server-side application failures
- Target Group Unhealthy Hosts
  - Detects failed EC2 instances behind the load balancer
- High Application Latency
  - Detects slow responses before full outages occur

All alarms trigger SNS email notifications for immediate visibility.

2. Incident Notifications
- SNS topic configured in the same region as workloads
- Email subscription confirmed for alert delivery
- Alarms publish directly to SNS

 3. Safe Lambda Rollback (Production Alias)
Critical Lambda functions use:
- Immutable versions
- A `prod` alias pointing to the active version

This enables:
- Zero-downtime deployments
- Instant rollback by repointing the alias

Rollback command:
```bash
aws lambda update-alias \
  --function-name CreateOrderFunction \
  --name prod \
  --function-version <PREVIOUS_VERSION>

