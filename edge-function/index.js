// Lambda@Edge Function for Canary Deployment Routing
// This function runs at CloudFront edge locations to route requests
// based on the user's organization membership

exports.handler = async (event) => {
  const request = event.Records[0].cf.request;
  const headers = request.headers;
  
  // Default to stable build
  let targetBuild = 'stable';
  let orgId = null;
  
  // Extract orgId from cookies
  if (headers.cookie && headers.cookie.length > 0) {
    const cookieString = headers.cookie[0].value;
    const cookieMatch = cookieString.match(/orgId=([^;]+)/);
    if (cookieMatch && cookieMatch[1]) {
      orgId = cookieMatch[1];
    }
  }
  
  // List of organizations in the canary rollout
  // In production, this would be fetched from a configuration service
  const rolloutOrgs = [
    'ORG_ABC',
    'ORG_TEST', 
    'ORG_CANARY',
    'ORG_BETA'
  ];
  
  // Route to next build if org is in rollout list
  if (orgId && rolloutOrgs.includes(orgId)) {
    targetBuild = 'next';
  }
  
  // Route to the appropriate S3 bucket based on build decision
  if (targetBuild === 'next') {
    // Route to the next build S3 bucket
    request.origin = {
      s3: {
        domainName: 'canary-demo-v2-dev-next.s3.amazonaws.com',
        region: 'us-east-1',
        authMethod: 'none',
        path: '',
        customHeaders: {}
      }
    };
  } else {
    // Route to the stable build S3 bucket  
    request.origin = {
      s3: {
        domainName: 'canary-demo-v2-dev-stable.s3.amazonaws.com',
        region: 'us-east-1',
        authMethod: 'none',
        path: '',
        customHeaders: {}
      }
    };
  }
  
  // Ensure we have proper URI for S3
  if (request.uri === '/') {
    request.uri = '/index.html';
  }
  
  // Add debug headers (Lambda@Edge format)
  request.headers['x-canary-build'] = [{ key: 'x-canary-build', value: targetBuild }];
  request.headers['x-canary-org'] = [{ key: 'x-canary-org', value: orgId || 'unknown' }];
  
  return request;
};