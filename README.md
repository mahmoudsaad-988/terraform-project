# Secure EC2 Instances with Shared RDS & EKS Cluster Infrastructure

This repository contains the **Infrastructure as Code (IaC)** configuration files to provision a secure, scalable, and highly available cloud footprint on AWS using **Terraform**. 

The repository details a multi-tier network featuring automated compute deployments, an isolated relational database tier, and an enterprise-grade **Amazon EKS (Elastic Kubernetes Service)** cluster topology utilizing a remote, state-locked S3 backend architecture.

---

## 🏗️ Architecture Overview

The codebase deploys two primary infrastructural stacks:

### 1. Application & Shared Database Architecture
* **VPC Layer (`AppVPC`):** Spans a dedicated `10.0.0.0/16` block featuring explicit DNS tracking support.
* **Subnet Layout:** Dual Availability Zone architecture (`us-east-1a` and `us-east-1b`) separating application ingress points.
* **Security & Perimeters:** Centralized stateful perimeter filtering (`WebTrafficSG`) regulating standard administration, web protocols (22, 80, 443), and targeted database transport layers (3306).
* **Compute Tier:** Elastic Compute Cloud instances (`WebServer1` and `WebServer2`) tied to static network interfaces and fortified with highly available Elastic IPs.
* **Database Layer:** Multi-AZ linked MySQL 8.0 RDS cluster mapping dynamically to an isolated DB subnet group.

### 2. Elastic Kubernetes Service (EKS) Topography
* **Dedicated Compute Networking (`eks_vpc`):** Complete isolation boundary isolating standard containers from baseline infrastructure.
* **Automated Node Scalability:** Managed node groups running on robust `t3.medium` instances dynamically configured to scale between 1 and 3 active workers depending on immediate platform load.
* **IAM RBAC Mapping:** Granular least-privilege identity access management policies covering AWS VPC CNI, EC2 Registry access, and baseline EKS cluster execution rights.

---

## 📂 Project Structure

```text
├── provider.tf        # AWS Provider and Remote S3 backend state configuration
├── main.tf            # Core App VPC, EC2 instances, and Shared RDS Database
├── eks.tf             # EKS Cluster, VPC, Node Groups, and IAM roles
├── variables.tf       # Input variable structures (Defines secure credentials)
├── terraform.tfvars   # Local runtime secrets (DO NOT COMMIT TO VERSION CONTROL)
└── README.md          # Project documentation 
