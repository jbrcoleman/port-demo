# Port S3 Bucket Provisioner

A self-service S3 bucket provisioning platform using Port as the developer portal and Terraform for infrastructure automation.

## Project Structure

```
port-s3-provisioner/
├── .github/
│   └── workflows/
│       └── provision-s3.yml
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── terraform.tfvars.template
├── port-config/
│   ├── blueprint.json
│   └── action.json
├── scripts/
│   └── setup-port.sh
├── README.md
└── .gitignore
```

## Prerequisites

- AWS Account with appropriate permissions
- Port account (free tier available)
- GitHub repository with Actions enabled
- Terraform Cloud account (optional, can use GitHub Actions state)

## Setup Instructions

### 1. Fork/Clone this repository

### 2. Configure AWS Credentials in GitHub Secrets
Add these secrets to your GitHub repository:
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `AWS_REGION` (e.g., us-east-1)

### 3. Configure Port Credentials
Add these secrets to your GitHub repository:
- `PORT_CLIENT_ID`
- `PORT_CLIENT_SECRET`

### 4. Set up Port Blueprint and Action

Run the setup script to create the Port blueprint and action:

```bash
chmod +x scripts/setup-port.sh
./scripts/setup-port.sh
```

Or manually import the configurations from the `port-config/` directory into your Port workspace.

### 5. Configure Terraform Variables

Copy `terraform/terraform.tfvars.template` to `terraform/terraform.tfvars` and update with your values:

```hcl
aws_region = "us-east-1"
default_tags = {
  Environment = "demo"
  Project     = "port-s3-provisioner"
  ManagedBy   = "terraform"
}
```

## How It Works

1. **Developer Request**: Developer fills out a form in Port requesting an S3 bucket
2. **GitHub Action Trigger**: Port triggers a GitHub Action with the request parameters
3. **Terraform Execution**: GitHub Action runs Terraform to provision the S3 bucket
4. **Status Update**: Action updates Port with the provisioning status and bucket details
5. **Resource Tracking**: Created bucket is tracked as an entity in Port

## Usage

1. Go to your Port workspace
2. Navigate to the "S3 Buckets" catalog
3. Click "Create S3 Bucket"
4. Fill out the form:
   - Bucket Name Prefix
   - Environment (dev/staging/prod)
   - Purpose/Description
   - Enable Versioning (optional)
5. Submit the request
6. Monitor progress in the GitHub Actions tab
7. View the created bucket details in Port

## Features

- ✅ Self-service S3 bucket provisioning
- ✅ Environment-based naming conventions
- ✅ Automatic tagging and policies
- ✅ Versioning configuration
- ✅ Real-time status updates in Port
- ✅ Resource cleanup capabilities
- ✅ Cost estimation (basic)

## Extending the Platform

This project can be extended with:
- Approval workflows for production environments
- Cost budgets and alerts
- Automated lifecycle policies
- Integration with other AWS services
- Multi-cloud support

## Troubleshooting

### Common Issues

1. **Permission Denied**: Ensure AWS credentials have S3 and IAM permissions
2. **Port API Errors**: Check CLIENT_ID and CLIENT_SECRET are correct
3. **Terraform State Lock**: If using remote state, ensure proper backend configuration
