#!/bin/bash

# Script to create test users in Cognito User Pool for canary deployment demo

set -e

# Configuration
STACK_NAME="canary-demo-v2"
REGION="us-east-1"
TEMP_PASSWORD="TempPass123!"

echo "👥 Creating test users for canary deployment demo..."

# Get User Pool ID from CloudFormation
get_user_pool_id() {
  USER_POOL_ID=$(aws cloudformation describe-stacks \
    --stack-name "$STACK_NAME" \
    --region "$REGION" \
    --query 'Stacks[0].Outputs[?OutputKey==`UserPoolId`].OutputValue' \
    --output text)
  
  if [ -z "$USER_POOL_ID" ]; then
    echo "❌ Could not find User Pool ID. Make sure the stack is deployed."
    exit 1
  fi
  
  echo "🔍 Found User Pool ID: $USER_POOL_ID"
}

# Create a user with custom attributes
create_user() {
  local username=$1
  local email=$2
  local org_id=$3
  local description=$4
  
  echo "👤 Creating user: $username ($description)"
  
  # Create user
  aws cognito-idp admin-create-user \
    --user-pool-id "$USER_POOL_ID" \
    --username "$username" \
    --user-attributes \
      Name=email,Value="$email" \
      Name=email_verified,Value=true \
      Name=custom:orgId,Value="$org_id" \
    --temporary-password "$TEMP_PASSWORD" \
    --message-action SUPPRESS \
    --region "$REGION"
  
  # Set permanent password
  aws cognito-idp admin-set-user-password \
    --user-pool-id "$USER_POOL_ID" \
    --username "$username" \
    --password "$TEMP_PASSWORD" \
    --permanent \
    --region "$REGION"
  
  echo "✅ User $username created successfully!"
}

# Create test users
create_test_users() {
  echo "📋 Creating test users..."
  
  # User 1: Will see NEXT build (org in rollout)
  create_user "user1@example.com" "user1@example.com" "ORG_ABC" "Next build user"
  
  # User 2: Will see STABLE build (org not in rollout)
  create_user "user2@example.com" "user2@example.com" "ORG_XYZ" "Stable build user"
  
  # User 3: Will see NEXT build (org in rollout)
  create_user "user3@example.com" "user3@example.com" "ORG_TEST" "Next build user"
  
  # User 4: Will see STABLE build (org not in rollout)
  create_user "user4@example.com" "user4@example.com" "ORG_PROD" "Stable build user"
}

# Display user information
show_user_info() {
  echo ""
  echo "🎉 Test users created successfully!"
  echo ""
  echo "👥 Test Users:"
  echo "   Username: user1@example.com | Org: ORG_ABC | Build: NEXT"
  echo "   Username: user2@example.com | Org: ORG_XYZ | Build: STABLE"
  echo "   Username: user3@example.com | Org: ORG_TEST | Build: NEXT"
  echo "   Username: user4@example.com | Org: ORG_PROD | Build: STABLE"
  echo ""
  echo "🔑 All users have password: $TEMP_PASSWORD"
  echo ""
  echo "📋 Organizations in rollout (will see NEXT build):"
  echo "   - ORG_ABC"
  echo "   - ORG_TEST"
  echo "   - ORG_CANARY"
  echo "   - ORG_BETA"
  echo ""
  echo "🧪 Test the canary deployment by logging in with different users!"
}

# Main execution
main() {
  get_user_pool_id
  create_test_users
  show_user_info
}

main "$@"