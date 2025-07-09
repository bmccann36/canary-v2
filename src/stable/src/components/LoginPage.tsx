import React, { useState } from 'react';
import { signIn, fetchUserAttributes } from 'aws-amplify/auth';
import './LoginPage.css';

interface LoginPageProps {
  onLoginSuccess: (user: any) => void;
}

const LoginPage: React.FC<LoginPageProps> = ({ onLoginSuccess }) => {
  const [username, setUsername] = useState('');
  const [password, setPassword] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setError('');

    try {
      const user = await signIn({ username, password });
      
      // Get user attributes to extract orgId
      const userAttributes = await fetchUserAttributes();
      const orgId = userAttributes['custom:orgId'] || 'ORG_DEFAULT';
      
      // Set orgId cookie
      document.cookie = `orgId=${orgId}; path=/; max-age=86400`; // 24 hours
      
      onLoginSuccess(user);
    } catch (err: any) {
      setError(err.message || 'Login failed');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="login-container">
      <div className="login-card">
        <h2>Login to Canary Demo</h2>
        <div className="build-banner stable-banner">
          STABLE BUILD
        </div>
        
        <form onSubmit={handleLogin}>
          <div className="form-group">
            <label htmlFor="username">Username (Email)</label>
            <input
              type="email"
              id="username"
              value={username}
              onChange={(e) => setUsername(e.target.value)}
              required
              disabled={loading}
            />
          </div>
          
          <div className="form-group">
            <label htmlFor="password">Password</label>
            <input
              type="password"
              id="password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              required
              disabled={loading}
            />
          </div>
          
          {error && <div className="error-message">{error}</div>}
          
          <button type="submit" disabled={loading}>
            {loading ? 'Signing In...' : 'Sign In'}
          </button>
        </form>
        
        <div className="demo-info">
          <p>Demo users:</p>
          <ul>
            <li>user1@example.com (ORG_ABC) - Will see NEXT build</li>
            <li>user2@example.com (ORG_XYZ) - Will see STABLE build</li>
          </ul>
        </div>
      </div>
    </div>
  );
};

export default LoginPage;