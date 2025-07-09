#!/bin/bash

# Build script for canary deployment demo
# Builds both stable and next React applications

set -e

echo "🚀 Starting build process for canary deployment demo..."

# Function to build a React app
build_app() {
  local app_name=$1
  local app_path=$2
  
  echo "📦 Building $app_name app..."
  
  cd "$app_path"
  
  # Check if node_modules exists
  if [ ! -d "node_modules" ]; then
    echo "📋 Installing dependencies for $app_name..."
    npm install
  fi
  
  # Build the app
  echo "🔨 Building $app_name..."
  npm run build
  
  echo "✅ $app_name build completed successfully!"
  
  # Go back to root
  cd - > /dev/null
}

# Build stable app
build_app "stable" "./src/stable"

# Build next app  
build_app "next" "./src/next"

echo ""
echo "🎉 All builds completed successfully!"
echo ""
echo "📁 Build outputs:"
echo "   - Stable build: ./src/stable/dist"
echo "   - Next build: ./src/next/dist"
echo ""
echo "🔄 Next steps:"
echo "   1. Deploy infrastructure: npm run deploy"
echo "   2. Upload builds to S3 buckets"
echo "   3. Update CloudFront edge function"
echo ""