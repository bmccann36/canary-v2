#!/bin/bash

# Local demo script for canary deployment
# Runs both stable and next apps locally for demonstration

set -e

echo "🎬 Starting local canary deployment demo..."

# Function to kill background processes on exit
cleanup() {
  echo "🧹 Cleaning up background processes..."
  jobs -p | xargs -r kill
  exit 0
}
trap cleanup EXIT

# Check if ports are available
check_port() {
  local port=$1
  if lsof -i :$port >/dev/null 2>&1; then
    echo "❌ Port $port is already in use"
    return 1
  fi
  return 0
}

# Start a React app in the background
start_app() {
  local app_name=$1
  local app_path=$2
  local port=$3
  
  echo "🚀 Starting $app_name on port $port..."
  
  cd "$app_path"
  
  # Check if node_modules exists
  if [ ! -d "node_modules" ]; then
    echo "📦 Installing dependencies for $app_name..."
    npm install
  fi
  
  # Start the app
  VITE_PORT=$port npm run dev &
  
  # Store the PID
  local pid=$!
  echo "   PID: $pid"
  
  # Go back to root
  cd - > /dev/null
  
  return 0
}

# Main demo function
run_demo() {
  echo "🔍 Checking port availability..."
  check_port 3000 || exit 1
  check_port 3001 || exit 1
  
  echo "📦 Building applications..."
  chmod +x scripts/build.sh
  ./scripts/build.sh
  
  echo "🎯 Starting local demo servers..."
  
  # Start stable app on port 3000
  start_app "Stable" "./src/stable" 3000
  
  # Start next app on port 3001
  start_app "Next" "./src/next" 3001
  
  echo ""
  echo "🎉 Local demo is running!"
  echo ""
  echo "🌐 Access the applications:"
  echo "   📗 Stable build: http://localhost:3000"
  echo "   📙 Next build:   http://localhost:3001"
  echo ""
  echo "🧪 Demo Instructions:"
  echo "   1. Visit both URLs to see the different builds"
  echo "   2. Note the different banners (GREEN vs ORANGE)"
  echo "   3. In a real deployment, users would be routed automatically"
  echo "   4. The edge function would read orgId cookies to determine routing"
  echo ""
  echo "⚙️  For AWS deployment:"
  echo "   - Configure AWS credentials: aws configure"
  echo "   - Ensure proper IAM permissions"
  echo "   - Run: npm run deploy"
  echo ""
  echo "🛑 Press Ctrl+C to stop the demo servers"
  
  # Wait for user to interrupt
  wait
}

# Run the demo
run_demo