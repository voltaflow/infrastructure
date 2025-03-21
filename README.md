# Infrastructure Repository

## Overview
This repository contains the infrastructure code and automation for managing cloud environments using **Terraform**, **Ansible**, **Kubernetes**, **Helm**, and **CI/CD pipelines** using **GitHub Actions**.

## Technologies Used
- **Terraform**: Infrastructure as Code (IaC) for provisioning cloud resources.
- **Ansible**: Configuration management and automation.
- **Kubernetes**: Container orchestration for deploying applications.
- **Helm**: Package manager for Kubernetes applications.
- **Networking & Security**: IAM, VPC, firewall rules, and TLS certificates.
- **Monitoring & Logging**: Prometheus, Grafana, Loki, Fluentd, ELK Stack.
- **CI/CD**: GitHub Actions for automation and deployments.

## Repository Structure
```
Infrastructure/
├── terraform/                   # Infrastructure provisioning with Terraform
│   ├── modules/                 # Reusable Terraform modules
│   ├── environments/            # Environment-specific configurations
│   ├── main.tf                  # Main configuration
├── ansible/                     # Configuration management with Ansible
│   ├── playbooks/               # Ansible playbooks
│   ├── inventories/             # Host inventories
│   ├── roles/                   # Modular roles
├── k8s/                         # Kubernetes manifests
│   ├── deployments/             # Deployment YAMLs
│   ├── services/                # Service configurations
│   ├── ingress/                 # Ingress configurations
│   ├── configmaps/              # Configuration maps
│   ├── secrets/                 # Secret management
├── helm/                        # Helm charts for Kubernetes applications
│   ├── charts/                  # Custom Helm charts
│   ├── values.yaml              # Default values for Helm
├── networking/                  # Network configurations
│   ├── vpc.tf                   # VPC definitions
│   ├── security-groups.tf       # Security groups and firewall rules
├── security/                    # Security configurations
│   ├── iam.tf                   # IAM roles and policies
│   ├── firewalls.tf             # Firewall rules
│   ├── tls-certificates/        # SSL/TLS Certificates
├── monitoring/                  # Monitoring stack (Prometheus, Grafana, etc.)
│   ├── prometheus/              # Prometheus configuration
│   ├── grafana/                 # Dashboards and visualizations
│   ├── alertmanager/            # Alerting rules
├── logging/                     # Centralized logging configuration
│   ├── loki/                    # Loki for log aggregation
│   ├── fluentd/                 # Fluentd for log processing
│   ├── elk-stack/               # ELK stack configurations
├── ci-cd/                       # CI/CD pipelines with GitHub Actions
│   ├── github-actions/          # Workflow definitions
│   │   ├── terraform.yml        # Infrastructure deployment workflow
│   │   ├── ansible.yml          # Configuration management workflow
│   │   ├── k8s-deploy.yml       # Kubernetes deployment workflow
│   │   ├── helm-deploy.yml      # Helm deployment workflow
│   │   ├── security-checks.yml  # Security analysis workflows
│   ├── scripts/                 # Helper scripts for automation
├── docs/                        # Documentation
│   ├── architecture-diagram.png # Infrastructure architecture
│   ├── runbook.md               # Operational guides
```

## Setup & Usage

### **1. Terraform Setup**
```sh
cd terraform
terraform init
terraform plan -var-file=environments/dev.tfvars
terraform apply -var-file=environments/dev.tfvars
```

### **2. Ansible Setup**
```sh
cd ansible
ansible-playbook -i inventories/dev setup.yml
```

### **3. Kubernetes Deployment**
```sh
kubectl apply -f k8s/deployments/
kubectl apply -f k8s/services/
```

### **4. Helm Deployment**
```sh
helm install my-app helm/charts/app-chart/
```

## CI/CD Pipeline (GitHub Actions)
The **ci-cd/github-actions/** folder contains multiple workflows to automate infrastructure provisioning, configuration, and deployments.

### **GitHub Actions Workflows**
| Workflow Name           | Purpose |
|------------------------|--------------------------------------------------------------|
| `terraform.yml`       | Runs Terraform `plan` and `apply` to provision infrastructure |
| `ansible.yml`         | Executes Ansible playbooks for configuration management |
| `k8s-deploy.yml`      | Deploys applications and updates Kubernetes manifests |
| `helm-deploy.yml`     | Deploys Helm charts to Kubernetes |
| `security-checks.yml` | Runs security audits on infrastructure and dependencies |

### **Running Workflows Manually**
You can manually trigger a workflow using the GitHub CLI:
```sh
gh workflow run terraform.yml -f environment=dev
gh workflow run ansible.yml -f playbook=setup.yml
gh workflow run k8s-deploy.yml -f app=my-app
gh workflow run helm-deploy.yml -f release=my-release
gh workflow run security-checks.yml
```

## Contributing
1. Fork the repository.
2. Create a new branch (`git checkout -b feature-branch`).
3. Commit changes (`git commit -m "Description of changes"`).
4. Push to the branch (`git push origin feature-branch`).
5. Open a Pull Request.

## License
This project is licensed under the MIT License.

---
For detailed guidelines, refer to [CLAUDE.md](CLAUDE.md).

