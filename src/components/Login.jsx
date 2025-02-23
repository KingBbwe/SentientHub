import React, { useState, useEffect } from 'react';
import { Actor, HttpAgent } from '@dfinity/agent';
import { idlFactory as IdentityBridgeIDL } from '../declarations/IdentityBridge.did';
import { useNavigate } from 'react-router-dom';
import { authenticateUser } from '../api/auth';

const IDENTITY_BRIDGE_CANISTER_ID = 'your-identity-bridge-canister-id';

function Login() {
  const [loading, setLoading] = useState(true);
  const [identity, setIdentity] = useState(null);
  const navigate = useNavigate();
  const agent = new HttpAgent();
  const identityBridge = Actor.createActor(IdentityBridgeIDL, {
    agent,
    canisterId: IDENTITY_BRIDGE_CANISTER_ID,
  });

  async function handleLogin() {
    // Use the authentication API to retrieve user principal
    const { principal } = await authenticateUser();
    try {
      const identityData = await identityBridge.getIdentity(principal);
      if (identityData) {
        setIdentity(identityData);
        navigate('/dashboard');
      } else {
        alert("No identity found. Please create your identity in Identity Forge.");
      }
    } catch (error) {
      console.error("Error retrieving identity:", error);
      alert("Error retrieving identity.");
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => {
    handleLogin();
  }, []);

  if (loading) return <div>Loading identity...</div>;
  if (!identity) return <div>No identity available. Please register your identity.</div>;

  return <div>Redirecting...</div>;
}

export default Login;
