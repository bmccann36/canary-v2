# Canary Deployment Demo v2

A minimal demo app showcasing canary deployment architecture with edge-based routing.

## Architecture

- **Single React App** (`src/app/`) - Unified codebase with environment-based builds
- **Stable Build** (`src/stable/`) - Production-ready version (build output)
- **Next Build** (`src/next/`) - Canary version for testing (build output)
- **CloudFront Function** - Edge routing based on org membership
- **AWS Cognito** - User authentication and org management

### Key Architecture Decision

This implementation uses a **single codebase** approach where the same React application is built twice with different environment variables (`VITE_BUILD_TYPE=stable` and `VITE_BUILD_TYPE=next`). This is more maintainable than separate codebases and mirrors real-world deployment patterns where the same code is deployed at different Git SHAs.

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
│   ├── app/             # Single React app (source code)
│   ├── stable/          # Stable build output (gitignored)
│   ├── next/            # Next build output (gitignored)
├── edge-function/       # CloudFront edge function
├── template.yaml        # AWS SAM template
└── scripts/            # Build and deploy scripts
```

### Build Process

The build process works as follows:

1. **Source Code**: Single React app in `src/app/` with environment-based configuration
2. **Build Variants**: Same codebase built twice with different `VITE_BUILD_TYPE` values:
   - `VITE_BUILD_TYPE=stable` → produces stable build with green banner and v1.0.0
   - `VITE_BUILD_TYPE=next` → produces next build with orange banner and v2.0.0-canary
3. **Build Outputs**: Generated builds are copied to `src/stable/` and `src/next/` directories
4. **Deployment**: Both build outputs are uploaded to separate S3 buckets
5. **Edge Routing**: CloudFront edge function routes users based on their `orgId` cookie