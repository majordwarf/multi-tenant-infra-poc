<h1 align="center">🤹 Multi-Tenant Multi Cloud Infra Deployment POC </h1>

---

<p align="center">
  <a href="#tooling">■ Tooling</a>&nbsp;&nbsp;
  <a href="#project-structure">■ Project Structure</a>&nbsp;&nbsp;
  <a href="#architechture">■ Architechture</a>&nbsp;&nbsp;
  <a href="#how-to-use">■ How To Use</a>&nbsp;&nbsp;
  <a href="#future-improvements">■ Future Improvements</a>&nbsp;&nbsp;
</p>

---

## Tooling

```
Terraform  - Infrastructure As Code Tool
Kubernetes - Cloud Native Container Orchestration
Helm       - Package Manager For Kubernetes
```

#### Project Structure:
```
├── app/                             - Helm Chart
│   ├── templates/                   - Helm templates
│   │   ├── _helpers.tpl             - Partial and Helper templates
│   │   ├── backend-deployment.yaml  - BE Deployment configuration
│   │   ├── backend-service.yaml     - BE Service configuration
│   │   ├── frontend-deployment.yaml - FE Deployment configuration
│   │   ├── frontend-ingress.yaml    - FE Ingress configuration
│   │   ├── frontend-service.yaml    - FE Service configuration
│   │   ├── kafka-cluster.yaml       - Kafka Cluster configuration
│   │   └── postgres-cluster.yaml    - Postgres Cluster configuration
│   ├── Chart.yaml                   - Helm Chart metadata
│   └── values.yaml                  - Helm Chart values
├── base/                            - Terraform configuration
│   ├── modules/                     - Reusable modules
│   │   ├── ***/main.tf              - Module configuration
│   │   ├── ***/outputs.tf           - Module outputs
│   │   └── ***/variables.tf         - Module variables
│   ├── main.tf                      - Main configuration
│   ├── providers.tf                 - Provider configuration
│   ├── terraform.tfvars             - Terraform variables
│   └── variables.tf                 - Terraform variables declaration
└── README.md                        - <-- You are here
```

## Architechture

The infrastructure is defined using Terraform and is composed of several modules to manage different components of the different cloud providers based on input. Below is an overview of the architecture:

### Modules

#### Infrastructure Modules

1. Clusters Module
   - Purpose: Manages the creation and configuration of Kubernetes clusters across different cloud providers (AWS, Azure, GCP).
   - Configuration:
     - cluster_name
     - provider_type
     - region
     - node_count
     - node_size
     - environment
     - network_config
     - common_tags
   - Providers:
     - AWS: aws
     - Azure: azurerm
     - GCP: google

2. Security Module
   - Purpose: Manages security configurations such as network policies, pod security policies, and cloud-specific security groups.
   - Configuration:
     - cluster_name
     - cluster_id
     - provider_type
     - environment
     - network_config

3. RBAC Module
   - Purpose: Manages Role-Based Access Control (RBAC) configurations including namespaces, service accounts, and role bindings.
   - Configuration:
     - cluster_name
     - provider_type
     - namespaces
     - service_accounts
     - environment

#### Application Deployment Modules

1. Chart Metadata
   - File: Chart.yaml
   - Description: Defines the metadata for the Helm chart, including the name, version, description, and dependencies.
   - Dependencies:
     - PostgreSQL Operator: postgresql-operator from CrunchyData
     - Kafka Operator: kafka-operator from Strimzi

2. Values Configuration
   - File: values.yaml
   - Description: Contains the default configuration values for the Helm chart, including settings for the frontend, backend, PostgreSQL, and Kafka.
   - Key Sections:
     - frontend: Configuration for the frontend application.
     - backend: Configuration for the backend application.
     - postgresql: Configuration for PostgreSQL deployment.
     - kafka: Configuration for Kafka deployment.

4. Templates
   - Directory: templates
   - Description: Contains the Kubernetes resource templates that are rendered using the values from values.yaml.
   - Key Templates:
     - Frontend:
       - Deployment: frontend-deployment.yaml
       - Service: frontend-service.yaml
       - Ingress: frontend-ingress.yaml
    - Backend:
       - Deployment: backend-deployment.yaml
       - Service: backend-service.yaml
    - Kafka:
       - Cluster: kafka-cluster.yaml
    - PostgreSQL:
       - Cluster: postgres-cluster.yaml
    - Helpers:
       - Common Labels and Selectors: _helpers.tpl

### Key Features

#### Infrastructure

- Single interface for all three major cloud providers
- Separation of concerns (each component has its directory)
- Consistent node pool configuration
- Sets up provider RBAC and security configuration for each cloud platform (AWS, Azure, GCP)
  - RBAC:
    - Three-tier role system (Admin, Developer, Viewer)
    - Namespace-level access control
    - Service account management
    - Cloud-provider specific RBAC integration
    - Environment segregation
  - Network Security:
    - Default deny network policies for all namespaces
    - Allowed DNS egress for pod communication
    - Cloud-specific security groups and firewall rules
    - Limited API server access through CIDR blocks
  - Security Tools:
    - Cert-manager for certificate management
    - HashiCorp Vault for secrets management
- Allows you to define:
  - Multiple namespaces
  - Service accounts with specific roles
  - Role bindings at both cluster and namespace level

#### Application Deployment

- Helm chart for deploying the application
- Configurable values for frontend, backend, PostgreSQL, and Kafka
- Templates for frontend, backend, PostgreSQL, and Kafka resources
- Support both dedicated and existing PostgreSQL and Kafka deployments (for privacy sensitive customers)

### How To Use:

To deploy the infrastructure and application, follow these steps:
```
> cd base
# Update terraform.tfvars with your cloud provider credentials
# Export the required environment variables for the cloud provider credentials to your shell
> terraform init
> terraform apply
```

To deploy the application, follow these steps:
```
> cd app
# Update values.yaml with your application configuration
> helm dependency update helm-charts/full-stack-app
> helm install full-stack-app helm-charts/full-stack-app -f values.yaml
```

### Future Improvements:
- Add support for logging and monitoring tools
- Add support for CI/CD pipelines
- Implement a backup and restore strategy
- Harden base node image using CIS benchmarks
