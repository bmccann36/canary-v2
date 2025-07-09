# Deployment Guide

## Quick Start Options

### Option 1: Local Demo (Recommended for Testing)

```bash
# Run both apps locally without AWS
npm run local-demo
```

This will:
- Start stable build on `http://localhost:3000`
- Start next build on `http://localhost:3001`
- Allow you to test both versions side by side

### Option 2: AWS Deployment (Full Production Setup)

```bash
# Deploy to AWS (requires AWS credentials)
npm run deploy
```

## AWS Deployment Prerequisites

### 1. AWS CLI Configuration

```bash
# Configure AWS credentials
aws configure

# Verify configuration
aws sts get-caller-identity
```

### 2. Required IAM Permissions

Your AWS user needs these permissions:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "cloudformation:*",
        "s3:*",
        "cognito-idp:*",
        "cloudfront:*",
        "iam:CreateRole",
        "iam:AttachRolePolicy",
        "iam:PassRole"
      ],
      "Resource": "*"
    }
  ]
}
```

### 3. SAM CLI Installation

```bash
# Install SAM CLI
# macOS:
brew install aws-sam-cli

# Or follow: https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/serverless-sam-cli-install.html
```

## Deployment Steps

### 1. Build Applications

```bash
npm run build-all
```

### 2. Deploy Infrastructure

```bash
# Option A: Automated deployment
npm run deploy

# Option B: Guided deployment (interactive)
npm run deploy-guided

# Option C: Manual deployment
sam build
sam deploy --guided
```

### 3. Create Test Users

```bash
npm run create-users
```

### 4. Test the Demo

Visit the CloudFront URL provided in the deployment output.

## Troubleshooting

### Common Deployment Issues

#### 1. AWS Credentials Not Configured

**Error**: `The security token included in the request is invalid`

**Solution**:
```bash
aws configure
# Enter your AWS Access Key ID, Secret Access Key, and Region
```

#### 2. Insufficient IAM Permissions

**Error**: `User is not authorized to perform: cloudformation:DescribeStacks`

**Solution**: Contact your AWS administrator to add the required permissions listed above.

#### 3. SAM CLI Not Found

**Error**: `sam: command not found`

**Solution**:
```bash
# Install SAM CLI
brew install aws-sam-cli
```

#### 4. S3 Bucket Creation Error

**Error**: `Bucket already exists`

**Solution**: Update the stack name in `samconfig.toml` to use a unique name.

### Manual Deployment Alternative

If automated deployment fails:

```bash
# 1. Build the template
sam build

# 2. Deploy with guided prompts
sam deploy --guided

# 3. Upload builds manually
aws s3 sync src/stable/dist s3://your-stable-bucket/
aws s3 sync src/next/dist s3://your-next-bucket/
```

## Local Development

### Running Individual Apps

```bash
# Start stable app only
npm run start-stable

# Start next app only
npm run start-next
```

### Environment Variables

Create `.env` files in each app directory:

```bash
# src/stable/.env
VITE_AWS_REGION=us-east-1
VITE_USER_POOL_ID=your-user-pool-id
VITE_USER_POOL_CLIENT_ID=your-client-id

# src/next/.env
VITE_AWS_REGION=us-east-1
VITE_USER_POOL_ID=your-user-pool-id
VITE_USER_POOL_CLIENT_ID=your-client-id
```

## Demo Flow

1. **No Authentication**: Users see stable build by default
2. **After Login**: orgId cookie is set based on user attributes
3. **Edge Routing**: CloudFront function routes based on orgId
4. **Rollout Control**: Update rollout list to control which orgs see next build

## Support

If you encounter issues:

1. Check the [AWS SAM documentation](https://docs.aws.amazon.com/serverless-application-model/)
2. Verify your AWS credentials and permissions
3. Try the local demo first to ensure applications work
4. Use `sam logs` to troubleshoot deployment issues