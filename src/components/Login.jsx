// src/components/Login.jsx
import React, { useState, useEffect } from 'react';
import { Actor, HttpAgent } from '@dfinity/agent';
import { idlFactory as IdentityBridgeIDL } from '../declarations/IdentityBridge.did';

const IDENTITY_BRIDGE_CANISTER_ID = 'your-identity-bridge-canister-id';

export default function Login() {
  const [identity, setIdentity] = useState(null);
  const [loading, setLoading] = useState(true);
  const agent = new HttpAgent();
  const identityBridge = Actor.createActor(IdentityBridgeIDL, {
    agent,
    canisterId: IDENTITY_BRIDGE_CANISTER_ID,
  });

  async function handleLogin() {
    // Here we assume an authentication mechanism already provides the user's principal.
    const userPrincipal = /* retrieve authenticated Principal (e.g., from a wallet) */;
    try {
      const identityData = await identityBridge.getIdentity(userPrincipal);
      if (identityData) {
        setIdentity(identityData);
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

  if (!identity) return <div>No identity available.</div>;

  return (
    <div>
      <h1>Welcome, {identity.characterName}</h1>
      <p><strong>Personality Profile:</strong> {identity.personalityProfile}</p>
      <p>
        <strong>Core Traits:</strong> Conscious – {identity.coreTraits.conscious}, Unconscious – {identity.coreTraits.unconscious}
      </p>
      <p>
        <strong>Heritage:</strong> {identity.heritage.name} - {identity.heritage.description}
      </p>
      <p>
        <strong>Journey:</strong> {identity.journey.description} (Age Band: {identity.journey.ageBand})
      </p>
      {/* Additional profile details as needed */}
    </div>
  );
}
