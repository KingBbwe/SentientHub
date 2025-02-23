import React, { useEffect, useState } from 'react';
import { Actor, HttpAgent } from '@dfinity/agent';
import { idlFactory as IdentityBridgeIDL } from '../declarations/IdentityBridge.did';

const IDENTITY_BRIDGE_CANISTER_ID = 'your-identity-bridge-canister-id';

function IdentityProfile() {
  const [profile, setProfile] = useState(null);
  const agent = new HttpAgent();
  const identityBridge = Actor.createActor(IdentityBridgeIDL, {
    agent,
    canisterId: IDENTITY_BRIDGE_CANISTER_ID,
  });

  useEffect(() => {
    async function fetchProfile() {
      // Replace with actual principal retrieval (e.g., from an authentication library)
      const userPrincipal = "2vxsx-fae"; 
      const identityData = await identityBridge.getIdentity(userPrincipal);
      setProfile(identityData);
    }
    fetchProfile();
  }, []);

  if (!profile) {
    return <div>No profile available.</div>;
  }

  return (
    <div>
      <h1>{profile.characterName}</h1>
      <p><strong>Personality Profile:</strong> {profile.personalityProfile}</p>
      <p>
        <strong>Core Traits:</strong> Conscious – {profile.coreTraits.conscious}, Unconscious – {profile.coreTraits.unconscious}
      </p>
      <p>
        <strong>Heritage:</strong> {profile.heritage.name} - {profile.heritage.description}
      </p>
      <p>
        <strong>Journey:</strong> {profile.journey.description} (Age Band: {profile.journey.ageBand})
      </p>
    </div>
  );
}

export default IdentityProfile;
