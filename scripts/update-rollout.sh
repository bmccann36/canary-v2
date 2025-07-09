#!/bin/bash

# Script to update the rollout configuration for canary deployment

set -e

# Configuration
STACK_NAME="canary-demo-v2"
REGION="us-east-1"

echo "🔄 Updating rollout configuration..."

# Function to display current rollout status
show_current_rollout() {
  echo "📋 Current rollout organizations:"
  
  # This would normally read from the deployed edge function
  # For now, showing the static list from rollout-config.json
  if [ -f "rollout-config.json" ]; then
    echo "   From rollout-config.json:"
    cat rollout-config.json | jq -r '.rolloutOrganizations[] | "   - \(.orgId) (\(.name))"'
  fi
  
  echo ""
  echo "   From edge function (hardcoded):"
  echo "   - ORG_ABC"
  echo "   - ORG_TEST"
  echo "   - ORG_CANARY"
  echo "   - ORG_BETA"
  echo ""
}

# Function to add organization to rollout
add_org_to_rollout() {
  local org_id=$1
  local org_name=$2
  
  echo "➕ Adding $org_id to rollout..."
  
  # Update rollout-config.json
  if [ -f "rollout-config.json" ]; then
    # Create backup
    cp rollout-config.json rollout-config.json.bak
    
    # Add new organization
    jq --arg orgId "$org_id" --arg orgName "$org_name" \
      '.rolloutOrganizations += [{
        "orgId": $orgId,
        "name": $orgName,
        "addedDate": (now | strftime("%Y-%m-%dT%H:%M:%SZ")),
        "status": "active"
      }]' rollout-config.json > rollout-config.json.tmp
    
    mv rollout-config.json.tmp rollout-config.json
    
    echo "✅ Added $org_id to rollout configuration"
  else
    echo "❌ rollout-config.json not found"
  fi
}

# Function to remove organization from rollout
remove_org_from_rollout() {
  local org_id=$1
  
  echo "➖ Removing $org_id from rollout..."
  
  # Update rollout-config.json
  if [ -f "rollout-config.json" ]; then
    # Create backup
    cp rollout-config.json rollout-config.json.bak
    
    # Remove organization
    jq --arg orgId "$org_id" \
      '.rolloutOrganizations = (.rolloutOrganizations | map(select(.orgId != $orgId)))' \
      rollout-config.json > rollout-config.json.tmp
    
    mv rollout-config.json.tmp rollout-config.json
    
    echo "✅ Removed $org_id from rollout configuration"
  else
    echo "❌ rollout-config.json not found"
  fi
}

# Function to update edge function (placeholder)
update_edge_function() {
  echo "🔄 Updating edge function..."
  echo "⚠️  Note: Edge function update requires manual CloudFormation stack update"
  echo "    The rollout list is currently hardcoded in the edge function."
  echo "    In production, this would read from a configuration service."
  echo ""
  echo "📋 To update the edge function:"
  echo "   1. Modify the rolloutOrgs array in edge-function/index.js"
  echo "   2. Run: sam build && sam deploy"
  echo "   3. CloudFront will automatically use the updated function"
}

# Interactive menu
show_menu() {
  echo "🎛️  Rollout Configuration Management"
  echo ""
  echo "Choose an option:"
  echo "1) Show current rollout status"
  echo "2) Add organization to rollout"
  echo "3) Remove organization from rollout"
  echo "4) Update edge function (manual process)"
  echo "5) Exit"
  echo ""
  read -p "Enter your choice [1-5]: " choice
  
  case $choice in
    1)
      show_current_rollout
      ;;
    2)
      read -p "Enter organization ID: " org_id
      read -p "Enter organization name: " org_name
      add_org_to_rollout "$org_id" "$org_name"
      ;;
    3)
      read -p "Enter organization ID to remove: " org_id
      remove_org_from_rollout "$org_id"
      ;;
    4)
      update_edge_function
      ;;
    5)
      echo "👋 Goodbye!"
      exit 0
      ;;
    *)
      echo "❌ Invalid option"
      ;;
  esac
}

# Main execution
main() {
  if [ $# -eq 0 ]; then
    # Interactive mode
    while true; do
      show_menu
      echo ""
      read -p "Press Enter to continue..."
      echo ""
    done
  else
    # Command line mode
    case "$1" in
      "show")
        show_current_rollout
        ;;
      "add")
        if [ $# -lt 3 ]; then
          echo "Usage: $0 add <org_id> <org_name>"
          exit 1
        fi
        add_org_to_rollout "$2" "$3"
        ;;
      "remove")
        if [ $# -lt 2 ]; then
          echo "Usage: $0 remove <org_id>"
          exit 1
        fi
        remove_org_from_rollout "$2"
        ;;
      *)
        echo "Usage: $0 [show|add <org_id> <org_name>|remove <org_id>]"
        exit 1
        ;;
    esac
  fi
}

main "$@"