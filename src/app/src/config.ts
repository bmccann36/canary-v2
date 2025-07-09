export const awsConfig = {
  Auth: {
    Cognito: {
      region: import.meta.env.VITE_AWS_REGION || 'us-east-1',
      userPoolId: import.meta.env.VITE_USER_POOL_ID || '',
      userPoolClientId: import.meta.env.VITE_USER_POOL_CLIENT_ID || '',
    }
  }
};

const buildType = import.meta.env.VITE_BUILD_TYPE || 'STABLE';

export const APP_CONFIG = {
  buildType: buildType.toUpperCase(),
  version: buildType.toLowerCase() === 'next' ? '2.0.0-canary' : '1.0.0'
};