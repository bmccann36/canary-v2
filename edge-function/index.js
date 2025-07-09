// CloudFront Edge Function for Canary Deployment Routing
// This function runs at CloudFront edge locations to route requests
// based on the user's organization membership

function handler(event) {
  var request = event.request;
  var headers = request.headers;
  
  // Default to stable build
  var targetBuild = 'stable';
  var orgId = null;
  
  // Extract orgId from cookies
  if (headers.cookie && headers.cookie.value) {
    var cookieString = headers.cookie.value;
    var cookieMatch = cookieString.match(/orgId=([^;]+)/);
    if (cookieMatch && cookieMatch[1]) {
      orgId = cookieMatch[1];
    }
  }
  
  // List of organizations in the canary rollout
  // In production, this would be fetched from a configuration service
  var rolloutOrgs = [
    'ORG_ABC',
    'ORG_TEST', 
    'ORG_CANARY',
    'ORG_BETA'
  ];
  
  // Route to next build if org is in rollout list
  if (orgId && rolloutOrgs.includes(orgId)) {
    targetBuild = 'next';
  }
  
  // Modify the request URI to route to the appropriate build
  var originalUri = request.uri;
  
  // Handle root path and index requests
  if (originalUri === '/' || originalUri === '/index.html') {
    request.uri = `/${targetBuild}/index.html`;
  } else if (originalUri.startsWith('/static/')) {
    // Route static assets to the correct build
    request.uri = `/${targetBuild}${originalUri}`;
  } else if (!originalUri.startsWith('/stable/') && !originalUri.startsWith('/next/')) {
    // Route other paths to the correct build
    request.uri = `/${targetBuild}${originalUri}`;
  }
  
  // Add custom headers for debugging
  request.headers['x-canary-build'] = { value: targetBuild };
  request.headers['x-canary-org'] = { value: orgId || 'unknown' };
  
  return request;
}

// Export for testing
if (typeof module !== 'undefined' && module.exports) {
  module.exports = { handler };
}