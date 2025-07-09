#!/bin/bash

# Build script for canary deployment demo
# Builds the single React app twice with different environment variables

set -e

echo "🚀 Starting build process for canary deployment demo..."

# Function to build the app with specific build type
build_app() {
  local build_type=$1
  local output_dir=$2
  
  echo "📦 Building $build_type app..."
  
  cd "./src/app"
  
  # Check if node_modules exists
  if [ ! -d "node_modules" ]; then
    echo "📋 Installing dependencies..."
    npm install
  fi
  
  # Build the app with specific build type
  echo "🔨 Building $build_type with VITE_BUILD_TYPE=$build_type..."
  VITE_BUILD_TYPE=$build_type npm run build
  
  # Go back to root
  cd - > /dev/null
  
  # Copy build output to specific directory
  echo "📁 Copying build to $output_dir..."
  rm -rf "$output_dir"
  cp -r "./src/app/dist" "$output_dir"
  
  echo "✅ $build_type build completed successfully!"
}

# Build stable app
build_app "stable" "./src/stable"

# Build next app  
build_app "next" "./src/next"

echo ""
echo "🎉 All builds completed successfully!"
echo ""
echo "📁 Build outputs:"
echo "   - Stable build: ./src/stable"
echo "   - Next build: ./src/next"
echo ""
echo "🔄 Next steps:"
echo "   1. Deploy infrastructure: npm run deploy"
echo "   2. Upload builds to S3 buckets"
echo "   3. Update CloudFront edge function"
echo ""