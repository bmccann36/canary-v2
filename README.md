# Canary Deployment Demo v2

A minimal demo app showcasing canary deployment architecture with edge-based routing.

## Architecture

- **Stable Build** (`/stable/`) - Production-ready version
- **Next Build** (`/next/`) - Canary version for testing
- **CloudFront Function** - Edge routing based on org membership
- **AWS Cognito** - User authentication and org management

## Quick Start

1. Install dependencies:
   ```bash
   npm run install-all
   ```

2. Build both versions:
   ```bash
   npm run build-all
   ```

3. Deploy to AWS:
   ```bash
   npm run deploy
   ```

## Demo Flow

1. User lands on app → no cookie → serves stable build
2. User logs in → cookie with orgId is set
3. Edge routing checks if org is in rollout list
4. Routes to next build if org is in rollout, otherwise stable
5. Update rollout config to control which orgs see next build

## Project Structure

```
├── src/
│   ├── stable/          # Stable React app
│   ├── next/            # Next React app
├── edge-function/       # CloudFront edge function
├── infrastructure/      # AWS SAM template
└── scripts/            # Build and deploy scripts
```