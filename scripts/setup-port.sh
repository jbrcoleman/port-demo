#!/bin/bash

# Port S3 Bucket Provisioner Setup Script
# This script creates the necessary Port blueprint and action

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}🚀 Setting up Port S3 Bucket Provisioner${NC}"

# Check if required environment variables are set
if [ -z "$PORT_CLIENT_ID" ] || [ -z "$PORT_CLIENT_SECRET" ]; then
    echo -e "${RED}❌ Error: PORT_CLIENT_ID and PORT_CLIENT_SECRET environment variables must be set${NC}"
    echo "You can find these in your Port application settings."
    exit 1
fi

# Get Port access token
echo -e "${YELLOW}🔑 Getting Port access token...${NC}"
ACCESS_TOKEN=$(curl -s --location --request POST 'https://api.getport.io/v1/auth/access_token' \
--header 'Content-Type: application/json' \
--data-raw "{
    \"clientId\": \"$PORT_CLIENT_ID\",
    \"clientSecret\": \"$PORT_CLIENT_SECRET\"
}" | jq -r '.accessToken')

if [ "$ACCESS_TOKEN" == "null" ] || [ -z "$ACCESS_TOKEN" ]; then
    echo -e "${RED}❌ Failed to get access token. Please check your credentials.${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Access token obtained${NC}"

# Create S3 Bucket Blueprint
echo -e "${YELLOW}📋 Creating S3 Bucket blueprint...${NC}"
BLUEPRINT_RESPONSE=$(curl -s --location --request POST 'https://api.getport.io/v1/blueprints' \
--header 'Content-Type: application/json' \
--header "Authorization: Bearer $ACCESS_TOKEN" \
--data-raw "$(cat port-config/blueprint.json)")

if echo "$BLUEPRINT_RESPONSE" | jq -e '.ok' > /dev/null 2>&1; then
    echo -e "${GREEN}✅ S3 Bucket blueprint created successfully${NC}"
else
    echo -e "${YELLOW}⚠️  Blueprint might already exist or there was an issue:${NC}"
    echo "$BLUEPRINT_RESPONSE" | jq '.message // .'
fi

# Update action configuration with current GitHub details
echo -e "${YELLOW}🔧 Configuring GitHub action...${NC}"

# Try to get GitHub org and repo from git remote
if git remote get-url origin &>/dev/null; then
    REMOTE_URL=$(git remote get-url origin)
    if [[ $REMOTE_URL =~ github\.com[:/]([^/]+)/([^/]+)(\.git)?$ ]]; then
        GITHUB_ORG="${BASH_REMATCH[1]}"
        GITHUB_REPO="${BASH_REMATCH[2]}"
        GITHUB_REPO="${GITHUB_REPO%.git}"  # Remove .git suffix if present
        
        echo -e "${GREEN}✅ Detected GitHub org: $GITHUB_ORG, repo: $GITHUB_REPO${NC}"
        
        # Update action configuration
        cat port-config/action.json | \
        jq --arg org "$GITHUB_ORG" --arg repo "$GITHUB_REPO" \
        '.invocationMethod.org = $org | .invocationMethod.repo = $repo' > /tmp/action.json
        
        mv /tmp/action.json port-config/action.json
    else
        echo -e "${YELLOW}⚠️  Could not parse GitHub details from remote URL. Please update action.json manually.${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  Not in a git repository. Please update action.json with your GitHub org and repo.${NC}"
fi

# Create Action
echo -e "${YELLOW}⚡ Creating provision S3 bucket action...${NC}"
ACTION_RESPONSE=$(curl -s --location --request POST 'https://api.getport.io/v1/blueprints/s3Bucket/actions' \
--header 'Content-Type: application/json' \
--header "Authorization: Bearer $ACCESS_TOKEN" \
--data-raw "$(cat port-config/action.json)")

if echo "$ACTION_RESPONSE" | jq -e '.ok' > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Provision S3 bucket action created successfully${NC}"
else
    echo -e "${YELLOW}⚠️  Action might already exist or there was an issue:${NC}"
    echo "$ACTION_RESPONSE" | jq '.message // .'
fi

echo ""
echo -e "${GREEN}🎉 Setup complete!${NC}"
echo ""
echo "Next steps:"
echo "1. 🔐 Add AWS credentials to your GitHub repository secrets:"
echo "   - AWS_ACCESS_KEY_ID"
echo "   - AWS_SECRET_ACCESS_KEY" 
echo "   - AWS_REGION"
echo ""
echo "2. 🔑 Add Port credentials to your GitHub repository secrets:"
echo "   - PORT_CLIENT_ID"
echo "   - PORT_CLIENT_SECRET"
echo ""
echo "3. 🚀 Visit your Port workspace to start provisioning S3 buckets!"
echo ""
echo "📚 For more information, check the README.md file."