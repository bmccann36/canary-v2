import React from 'react';
import { signOut } from 'aws-amplify/auth';
import { APP_CONFIG } from '../config';
import './HomePage.css';

interface HomePageProps {
  user: any;
  onLogout: () => void;
}

const HomePage: React.FC<HomePageProps> = ({ user, onLogout }) => {
  const handleLogout = async () => {
    try {
      await signOut();
      // Clear orgId cookie
      document.cookie = 'orgId=; path=/; expires=Thu, 01 Jan 1970 00:00:01 GMT;';
      onLogout();
    } catch (error) {
      console.error('Error signing out:', error);
    }
  };

  const getCookieValue = (name: string) => {
    const value = `; ${document.cookie}`;
    const parts = value.split(`; ${name}=`);
    if (parts.length === 2) return parts.pop()?.split(';').shift();
    return null;
  };

  const orgId = getCookieValue('orgId');

  return (
    <div className="home-container">
      <header className="home-header">
        <h1>Canary Demo Application</h1>
        <button onClick={handleLogout} className="logout-btn">
          Logout
        </button>
      </header>
      
      <div className="content">
        <div className="build-banner next-banner">
          {APP_CONFIG.buildType} BUILD
        </div>
        
        <div className="welcome-section">
          <h2>Welcome back!</h2>
          <p>You are successfully logged in to the {APP_CONFIG.buildType.toLowerCase()} build.</p>
        </div>
        
        <div className="info-cards">
          <div className="info-card">
            <h3>User Information</h3>
            <p><strong>Username:</strong> {user.username}</p>
            <p><strong>Organization:</strong> {orgId || 'Not set'}</p>
            <p><strong>Build Version:</strong> {APP_CONFIG.version}</p>
          </div>
          
          <div className="info-card">
            <h3>Build Information</h3>
            <p><strong>Build Type:</strong> {APP_CONFIG.buildType}</p>
            <p><strong>Features:</strong> New features and improvements</p>
            <p><strong>Status:</strong> Canary testing</p>
          </div>
          
          <div className="info-card">
            <h3>Demo Instructions</h3>
            <p>This is the <strong>next build</strong> of the application.</p>
            <p>You're seeing this because your organization is in the canary rollout list.</p>
            <p>Try logging in with different demo accounts to see the routing in action.</p>
          </div>
        </div>
        
        <div className="actions">
          <button onClick={() => window.location.reload()} className="refresh-btn">
            Refresh Page
          </button>
          <button onClick={() => {
            const newOrgId = prompt('Enter new orgId for testing:');
            if (newOrgId) {
              document.cookie = `orgId=${newOrgId}; path=/; max-age=86400`;
              window.location.reload();
            }
          }} className="test-btn">
            Test Different Org
          </button>
        </div>
      </div>
    </div>
  );
};

export default HomePage;