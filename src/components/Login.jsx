import React, { useState, useEffect } from 'react';
import { Actor, HttpAgent } from '@dfinity/agent';
import { idlFactory as IdentityBridgeIDL } from '../declarations/IdentityBridge.did';
import { useNavigate } from 'react-router-dom';
import { authenticateUser } from '../api/auth';

const IDENTITY_BRIDGE_CANISTER_ID = 'your-identity-bridge-canister-id';

function Login() {
  const [loading, setLoading] = useState(true);
  const navigate = useNavigate();
  const agent = new HttpAgent();
  const identityBridge = Actor.createActor(IdentityBridgeIDL, {
    agent,
    canisterId: IDENTITY_BRIDGE_CANISTER_ID,
  });

  useEffect(() => {
    async function handleLogin() {
      try {
        const { principal } = await authenticateUser();
        const identityData = await identityBridge.getIdentity(principal);
        if (identityData) {
          // Successful login; redirect to dashboard
          navigate('/dashboard');
        } else {
          alert("No identity found. Please create your identity using Identity Forge.");
          navigate('/create');
        }
      } catch (error) {
        console.error("Error during login:", error);
        alert("Login error. Please try again.");
      } finally {
        setLoading(false);
      }
    }
    handleLogin();
  }, [navigate, identityBridge]);

  if (loading) return <div>Loading identity...</div>;
  return <div>Redirecting...</div>;
}

export default Login;
