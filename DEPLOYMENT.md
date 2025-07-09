# Deployment Guide

## Quick Start Options

### Option 1: Local Demo (Recommended for Testing)

```bash
# Run stable build locally
npm run start-stable

# Or run next build locally
npm run start-next
```

This will:
- Start the single React app with the specified build type
- Stable build: `http://localhost:5173` with green banner and v1.0.0
- Next build: `http://localhost:5173` with orange banner and v2.0.0-canary
- Allows you to test both versions using the same codebase

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

This command:
- Builds the single React app twice with different `VITE_BUILD_TYPE` environment variables
- Creates stable build output in `src/stable/` directory
- Creates next build output in `src/next/` directory
- Both builds use the same source code from `src/app/`

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
aws s3 sync src/stable s3://your-stable-bucket/
aws s3 sync src/next s3://your-next-bucket/
```

## Local Development

### Running Different Build Types

```bash
# Start stable build (green banner, v1.0.0)
npm run start-stable

# Start next build (orange banner, v2.0.0-canary)
npm run start-next
```

### Environment Variables

Create a `.env` file in the app directory:

```bash
# src/app/.env
VITE_AWS_REGION=us-east-1
VITE_USER_POOL_ID=your-user-pool-id
VITE_USER_POOL_CLIENT_ID=your-client-id
```

The `VITE_BUILD_TYPE` environment variable is automatically set by the npm scripts to control which build variant is shown.

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