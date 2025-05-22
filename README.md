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

### 1. Verify GitHub Repository Settings
- [ ] Repository has Actions enabled
- [ ] Repository is public OR you have GitHub Pro/Enterprise for private repos
- [ ] The workflow file is in `.github/workflows/provision-s3.yml`

### 2. Check GitHub Secrets
Go to your repo → Settings → Secrets and variables → Actions and verify these exist:
- [ ] `PORT_CLIENT_ID`
- [ ] `PORT_CLIENT_SECRET`
- [ ] `AWS_ACCESS_KEY_ID`
- [ ] `AWS_SECRET_ACCESS_KEY`
- [ ] `AWS_REGION`

### 3. Verify Port Configuration

#### Check if Blueprint exists:
```bash
curl -X GET "https://api.getport.io/v1/blueprints/s3Bucket" \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```

#### Check if Action exists:
```bash
curl -X GET "https://api.getport.io/v1/blueprints/s3Bucket/actions" \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```

### 4. Update Port Action Configuration

Your Port action needs to be updated to use the new workflow format. Run this script:

```bash
#!/bin/bash

# Get Port access token
ACCESS_TOKEN=$(curl -s --location --request POST 'https://api.getport.io/v1/auth/access_token' \
--header 'Content-Type: application/json' \
--data-raw "{
    \"clientId\": \"$PORT_CLIENT_ID\",
    \"clientSecret\": \"$PORT_CLIENT_SECRET\"
}" | jq -r '.accessToken')

# Update the action
curl -X PUT "https://api.getport.io/v1/blueprints/s3Bucket/actions/provision_s3_bucket" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -d @port-config/action.json
```

## Step-by-Step Debugging

### Step 1: Test GitHub Action Manually
1. Go to your GitHub repository
2. Click Actions tab
3. Find "Provision S3 Bucket" workflow
4. Click "Run workflow"
5. Fill in the parameters manually
6. If this works, the issue is with Port integration

### Step 2: Check Port Logs
1. Go to Port workspace
2. Navigate to Audit Log (usually in settings)
3. Look for action execution logs
4. Check for any error messages

### Step 3: Verify Port-GitHub Integration
1. In Port, go to Settings → Integrations
2. Look for GitHub integration
3. Ensure it's connected to the correct repository
4. Check if the webhook is properly configured

### Step 4: Test Port Action
1. Fill out the S3 bucket form in Port
2. Check the "Runs" page in Port for execution status
3. If the run shows as "Running" but GitHub Action doesn't trigger, there's a webhook issue

## Common Issues and Solutions

### Issue 1: "Workflow not found"
**Solution**: 
- Ensure the workflow file is exactly at `.github/workflows/provision-s3.yml`
- The filename in Port action config must match exactly

### Issue 2: "Repository dispatch not supported"
**Solution**: 
- Update to use `workflow_dispatch` instead of `repository_dispatch`
- This is what the updated configuration above does

### Issue 3: "Permission denied"
**Solutions**:
- For private repos: Ensure you have GitHub Pro/Enterprise
- Check that Port has proper permissions to your repository
- Re-authenticate the GitHub integration in Port

### Issue 4: GitHub Action starts but fails
**Solutions**:
- Check all GitHub secrets are set correctly
- Verify AWS credentials have proper S3 permissions
- Check Terraform syntax in the workflow logs

## Testing the Fixed Configuration

1. **Update the workflow file** with the new configuration
2. **Update the Port action** using the script above
3. **Test the integration**:
   ```bash
   # Test 1: Manual GitHub Action
   # Go to Actions → Run workflow manually
   
   # Test 2: Port form submission
   # Fill out the form in Port
   
   # Test 3: Check logs
   # Monitor both Port and GitHub for execution
   ```

## Advanced Debugging

### Check Port Webhooks
```bash
# List all webhooks for your action
curl -X GET "https://api.getport.io/v1/blueprints/s3Bucket/actions/provision_s3_bucket/runs" \
  -H "Authorization: Bearer $ACCESS_TOKEN"
```

### Enable Debug Logging in GitHub Action
Add this step to your workflow for more verbose logging:
```yaml
- name: Debug Port Input
  run: |
    echo "Bucket prefix: ${{ github.event.inputs.bucket_prefix }}"
    echo "Environment: ${{ github.event.inputs.environment }}"
    echo "Port context: ${{ github.event.inputs.port_context }}"
```

## Getting Help

If you're still having issues:
1. Check the GitHub Actions logs for any error messages
2. Check Port's audit logs for webhook delivery status
3. Verify your Port workspace has the GitHub integration properly configured
4. Consider reaching out to Port support with specific error messages
