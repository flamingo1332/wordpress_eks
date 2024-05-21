## WordPress EKS Deployment Project

Automated deployment of AWS resources with Terraform and github actions. Use ArgoCD and the ArgoCD Vault Plugin to deploy using gitops methodology. The entire process is automated, requiring minimal manual intervention.

### Requirements
- aws account 


### Infrastructure and Tools
- **Terraform**: Provisions AWS resources 
- **ArgoCD**: Ensure the cluster's state matches the desired state declared in this repo.
- **GitHub Actions**: Automates infrastructure deployment


### Architecture
<diagram>


1. GitHub Actions automatically provisions the EKS cluster and necessary AWS resources using Terraform.

2. Terraform Helm Provider deploys ArgoCD and the ArgoCD Vault Plugin sidecar container to the EKS cluster.
3. ArgoCD deploys WordPress and other applications from the Git repository.
4. During this process, avp container fetches secrets from AWS Secrets Manager and injects them into the application manifests in the Git repository. Since the secret is stored in the argocd redis pod, access to that pod must be restricted for security



A key challenge with implementing GitOps using ArgoCD is securely managing secrets. Exposing secrets in the Git repository is not advisable. Although External Secrets Operator is a suitable solution, it does not allow direct annotation of secrets in the ArgoCD application manifest when deploying with Helm charts. 


Using ArgoCD Vault Plugin (sidecar container) was more appropriate, since it can easliy inject secrets into application manifests from secret management system. Argocd vault plugin was installed as a sidecar container using argocd helm chart [like this](https://github.com/flamingo1332/argocd_vault_plugin_installation_with_helm).

Also Terraform input variables can be used securely by leveraging the Terraform backend, ensuring they are not exposed.



### AWS Resources
- RDS Database for WordPress
- ACM Certificate
- VPC
    - 2Private, 2Public, 2DB Subnet
    - Internet Gateway
    - NAT Gateway

- EKS Cluster
    - Add-ons: VPC-CNI, CoreDNS, Kube-proxy

- IRSA IAM Roles for EKS Service Accounts
    - Cluster Autoscaler
    - ExternalDNS
    - AWS Load Balancer Controller
    - ArgoCD Vault Plugin
    - EBS CSI Driver

- AWS Secrets Manager for argocd
    - aws resource id, resource arns, passwords, etc. 
    - ArgoCD Vault Plugin sidecar container fetches secrets and injects them into ArgoCD application manifests for secure deployment.


- Application Load Balancer created by aws lb Controller
- DNS records created by externalDNS



### Helm Charts
argocd and argocd vault plugin sidecar container as helm_release terraform resource

wordpress, aws-lb-controller, cluster-autoscaler, externalDNS, kube-prometheus-stack, metrics-server as argocd application manifests. Secrets are stored in AWS Secrets Manager via Terraform, and the ArgoCD Vault Plugin sidecar container fetches the secrets and inject them into application manifests. 


### Inputs
| Variable                           | Type            | Description                                                       |
|------------------------------------|-----------------|-------------------------------------------------------------------|
| `aws_access_key`                   | `string`        | AWS access key                                                    |
| `aws_secret_key`                   | `string`        | AWS secret key                                                    |
| `aws_region`                       | `string`        | AWS region                                                        |
| `env`                              | `string`        | Environment setting                                               |
| `project_name`                     | `string`        | Project name                                                      |
| `domain_name`                      | `string`        | Domain name associated with the project                           |
| `slack_url`                        | `string`        | Slack URL for EKS monitoring notifications                        |
| `vpc_cidr`                         | `string`        | CIDR block for the VPC                                            |
| `vpc_azs`                          | `list(string)`  | List of availability zones in the region                          |
| `vpc_public_subnets`               | `list(string)`  | List of public subnets inside the VPC                             |
| `vpc_private_subnets`              | `list(string)`  | List of private subnets inside the VPC                            |
| `vpc_database_subnets`             | `list(string)`  | List of database subnets inside the VPC                           |
| `vpc_single_nat_gateway`           | `bool`          | Indicates if a single NAT gateway is used in the VPC              |
| `eks_cluster_version`              | `string`        | EKS cluster version                                               |
| `eks_cluster_endpoint_public_access` | `bool`        | Public access setting for EKS cluster endpoint                    |
| `eks_cluster_desired_size`         | `number`        | Desired size of the EKS managed node group                        |
| `eks_cluster_min_size`             | `number`        | Minimum size of the EKS managed node group                        |
| `eks_cluster_max_size`             | `number`        | Maximum size of the EKS managed node group                        |
| `eks_cluster_disk_size`            | `number`        | Disk size for EKS managed nodes                                   |
| `eks_cluster_label_role`           | `string`        | Role label for EKS managed nodes                                  |
| `eks_cluster_instance_types`       | `list(string)`  | List of instance types for EKS managed nodes                      |
| `eks_cluster_capacity_type`        | `string`        | Capacity type for EKS managed nodes                               |
| `secrets_manager_name`             | `string`        | Name for AWS Secrets Manager                                      |
| `db_engine`                        | `string`        | Database engine type                                              |
| `db_engine_version`                | `string`        | Database engine version                                           |
| `db_instance_class`                | `string`        | Database instance class                                           |
| `db_allocated_storage`             | `number`        | Allocated storage for the database                                |
| `db_name`                          | `string`        | Database name                                                     |
| `db_username`                      | `string`        | Username for the database                                         |
| `db_master_username`               | `string`        | Master username for the database                                  |



## Output