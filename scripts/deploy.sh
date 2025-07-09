#!/bin/bash

# Deployment script for canary deployment demo
# Deploys infrastructure and uploads builds to S3

set -e

# Configuration
STACK_NAME="canary-demo-v2"
REGION="us-east-1"
ENVIRONMENT="dev"

echo "🚀 Starting deployment process..."

# Check if required tools are installed
check_dependencies() {
  echo "🔍 Checking dependencies..."
  
  if ! command -v sam &> /dev/null; then
    echo "❌ AWS SAM CLI not found. Please install it first."
    echo "   https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/serverless-sam-cli-install.html"
    exit 1
  fi
  
  if ! command -v aws &> /dev/null; then
    echo "❌ AWS CLI not found. Please install it first."
    echo "   https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html"
    exit 1
  fi
  
  echo "✅ Dependencies check passed!"
}

# Build applications
build_apps() {
  echo "📦 Building applications..."
  chmod +x scripts/build.sh
  ./scripts/build.sh
}

# Deploy SAM stack
deploy_infrastructure() {
  echo "🏗️  Deploying infrastructure..."
  
  sam build
  
  echo "📋 Attempting deployment..."
  if sam deploy \
    --stack-name "$STACK_NAME" \
    --parameter-overrides \
      ProjectName="$STACK_NAME" \
      Environment="$ENVIRONMENT" \
    --capabilities CAPABILITY_IAM \
    --region "$REGION" \
    --no-confirm-changeset; then
    echo "✅ Infrastructure deployed successfully!"
  else
    echo "❌ Deployment failed!"
    echo ""
    echo "🔍 Common issues:"
    echo "   1. AWS credentials not configured: Run 'aws configure'"
    echo "   2. Insufficient IAM permissions for CloudFormation"
    echo "   3. S3 bucket for deployment not available"
    echo ""
    echo "🛠️  Try manual deployment:"
    echo "   sam deploy --guided"
    echo ""
    echo "📋 Required AWS permissions:"
    echo "   - CloudFormation: CreateStack, UpdateStack, DescribeStacks"
    echo "   - S3: CreateBucket, PutObject, GetObject"
    echo "   - Cognito: CreateUserPool, CreateUserPoolClient"
    echo "   - CloudFront: CreateDistribution, CreateFunction"
    echo "   - IAM: CreateRole, AttachRolePolicy"
    echo ""
    return 1
  fi
}

# Upload builds to S3
upload_builds() {
  echo "📤 Uploading builds to S3..."
  
  # Get bucket names from CloudFormation outputs
  STABLE_BUCKET=$(aws cloudformation describe-stacks \
    --stack-name "$STACK_NAME" \
    --region "$REGION" \
    --query 'Stacks[0].Outputs[?OutputKey==`StableBucketName`].OutputValue' \
    --output text)
  
  NEXT_BUCKET=$(aws cloudformation describe-stacks \
    --stack-name "$STACK_NAME" \
    --region "$REGION" \
    --query 'Stacks[0].Outputs[?OutputKey==`NextBucketName`].OutputValue' \
    --output text)
  
  # Upload stable build
  echo "📤 Uploading stable build to $STABLE_BUCKET..."
  aws s3 sync ./src/stable "s3://$STABLE_BUCKET" --delete
  
  # Upload next build
  echo "📤 Uploading next build to $NEXT_BUCKET..."
  aws s3 sync ./src/next "s3://$NEXT_BUCKET" --delete
  
  echo "✅ Builds uploaded successfully!"
}

# Display deployment information
show_deployment_info() {
  echo ""
  echo "🎉 Deployment completed successfully!"
  echo ""
  
  # Get CloudFront URL
  CLOUDFRONT_URL=$(aws cloudformation describe-stacks \
    --stack-name "$STACK_NAME" \
    --region "$REGION" \
    --query 'Stacks[0].Outputs[?OutputKey==`CloudFrontURL`].OutputValue' \
    --output text)
  
  # Get Cognito details
  USER_POOL_ID=$(aws cloudformation describe-stacks \
    --stack-name "$STACK_NAME" \
    --region "$REGION" \
    --query 'Stacks[0].Outputs[?OutputKey==`UserPoolId`].OutputValue' \
    --output text)
  
  USER_POOL_CLIENT_ID=$(aws cloudformation describe-stacks \
    --stack-name "$STACK_NAME" \
    --region "$REGION" \
    --query 'Stacks[0].Outputs[?OutputKey==`UserPoolClientId`].OutputValue' \
    --output text)
  
  echo "🌐 Application URL: $CLOUDFRONT_URL"
  echo "🔑 User Pool ID: $USER_POOL_ID"
  echo "📱 Client ID: $USER_POOL_CLIENT_ID"
  echo ""
  echo "⚙️  Environment variables for local development:"
  echo "   VITE_AWS_REGION=$REGION"
  echo "   VITE_USER_POOL_ID=$USER_POOL_ID"
  echo "   VITE_USER_POOL_CLIENT_ID=$USER_POOL_CLIENT_ID"
  echo ""
  echo "📋 Next steps:"
  echo "   1. Create test users in Cognito User Pool"
  echo "   2. Set custom:orgId attribute for users"
  echo "   3. Test the canary deployment flow"
  echo ""
}

# Main execution
main() {
  check_dependencies
  build_apps
  deploy_infrastructure
  upload_builds
  show_deployment_info
}

main "$@"