# GKE Helm & GCE Ingress Demo Repository

This repository is a demo project that showcases how to deploy services on Google Kubernetes Engine (GKE) using Helm, GCE Ingress Controller, and Terraform. The repository contains the following components:

- **Terraform**: Infrastructure as code for creating the GKE cluster, VPC, and static IP.
- **Helm Charts**: Helm charts for deploying two demo services (`svc1` and `svc2`) and GCE Ingress.
- **Kubernetes Manifests**: Raw Kubernetes YAML manifests to deploy the services and ingress without Helm.

## Repository Structure

```bash
GKE/
│
├── helm/                      # Contains Helm charts for svc1, svc2, and GCE ingress
│   ├── gce-ingress/
│   │   ├── charts/
│   │   ├── templates/          # Templates for GCE ingress
│   │   ├── Chart.yaml          # Chart metadata for GCE Ingress
│   │   ├── values.yaml         # Configurable values for GCE Ingress
│   │
│   ├── svc1/
│   │   ├── charts/
│   │   ├── templates/          # Templates for svc1
│   │   ├── Chart.yaml          # Chart metadata for svc1
│   │   ├── values.yaml         # Configurable values for svc1
│   │
│   ├── svc2/
│   │   ├── charts/
│   │   ├── templates/          # Templates for svc2
│   │   ├── Chart.yaml          # Chart metadata for svc2
│   │   ├── values.yaml         # Configurable values for svc2
│
├── manifests/                  # Raw Kubernetes manifests for deploying svc1, svc2, and ingress
│   ├── ingress.yaml            # Ingress resource for GCE
│   ├── svc1.yaml               # Deployment and service manifest for svc1
│   ├── svc2.yaml               # Deployment and service manifest for svc2
│
├── terraform/                  # Terraform code for GKE infrastructure
│   ├── gke.tf                  # GKE cluster configuration
│   ├── ingress-ip.tf           # Static IP configuration for ingress
│   ├── network.tf              # VPC and network configurations
│   ├── outputs.tf              # Outputs for GKE and networking resources
│   ├── providers.tf            # Providers configuration
│
├── .gitignore                  # Git ignore file
└── README.md                   # Project README file
```

## Requirements

- **Google Cloud Platform (GCP) Account**
- **Google Kubernetes Engine (GKE)**
- **kubectl** installed and configured to use your GKE cluster.
- **Helm** installed for deploying Helm charts.
- **Terraform** installed for managing infrastructure as code.

## Terraform Setup

1. Navigate to the `terraform/` directory.
2. Initialize Terraform:
   ```bash
   terraform init
   ```
3. Apply the Terraform configuration to provision the infrastructure (GKE cluster, VPC, and static IP):
   ```bash
   terraform apply
   ```

This will create:
- A **GKE Cluster** with a public subnet.
- A **Global Static IP** for GCE Ingress.
- Necessary **VPC and firewall rules**.

## Deploying with Helm

1. First, make sure you are connected to the GKE cluster:
   ```bash
   gcloud container clusters get-credentials <your-cluster-name> --zone <your-cluster-zone>
   ```

2. Deploy `svc1` using Helm:
   ```bash
   cd helm/svc1
   helm install svc1 . --namespace <your-namespace>
   ```

3. Deploy `svc2` using Helm:
   ```bash
   cd helm/svc2
   helm install svc2 . --namespace <your-namespace>
   ```

4. Deploy the GCE Ingress Controller using Helm:
   ```bash
   cd helm/gce-ingress
   helm install gce-ingress . --namespace <your-namespace>
   ```

This will expose the services at paths `/svc1` and `/svc2` using the static IP provisioned with Terraform.

## Deploying with Kubernetes Manifests

Alternatively, you can deploy the services and ingress using raw Kubernetes manifests without Helm.

1. Deploy `svc1`:
   ```bash
   kubectl apply -f manifests/svc1.yaml
   ```

2. Deploy `svc2`:
   ```bash
   kubectl apply -f manifests/svc2.yaml
   ```

3. Deploy the GCE Ingress:
   ```bash
   kubectl apply -f manifests/ingress.yaml
   ```

## Accessing the Services

After the services and ingress are deployed, you can access them using the static IP created in the Terraform step.

- **svc1**: `http://<static-ip>/svc1`
- **svc2**: `http://<static-ip>/svc2`

## Cleaning Up

To clean up the resources:

1. Uninstall Helm releases:
   ```bash
   helm uninstall svc1 --namespace <your-namespace>
   helm uninstall svc2 --namespace <your-namespace>
   helm uninstall gce-ingress --namespace <your-namespace>
   ```

2. Destroy the Terraform-managed infrastructure:
   ```bash
   cd terraform/
   terraform destroy
   ```

---
