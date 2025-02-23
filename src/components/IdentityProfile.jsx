import React, { useEffect, useState } from 'react';
import { Actor, HttpAgent } from '@dfinity/agent';
import { idlFactory as IdentityBridgeIDL } from '../declarations/IdentityBridge.did';

const IDENTITY_BRIDGE_CANISTER_ID = 'your-identity-bridge-canister-id';

function IdentityProfile({ identity }) {
  const [profile, setProfile] = useState(null);
  const agent = new HttpAgent({ identity });
  const identityBridge = Actor.createActor(IdentityBridgeIDL, {
    agent,
    canisterId: IDENTITY_BRIDGE_CANISTER_ID,
  });

  useEffect(() => {
    async function fetchProfile() {
      // In a real app, use identity.getPrincipal() or similar.
      const principal = identity ? identity.getPrincipal().toText() : "2vxsx-fae";
      const data = await identityBridge.getIdentity(principal);
      setProfile(data);
    }
    if (identity) {
      fetchProfile();
    }
  }, [identity, identityBridge]);

  if (!profile) return <div>Loading profile...</div>;

  return (
    <div className="p-4 border rounded">
      <h2>Identity Profile</h2>
      <p><strong>Name:</strong> {profile.characterName}</p>
      <p><strong>Personality Profile:</strong> {profile.personalityProfile}</p>
      <p>
        <strong>Core Traits:</strong> Conscious – {profile.coreTraits.conscious}, Unconscious – {profile.coreTraits.unconscious}
      </p>
      <p>
        <strong>Heritage:</strong> {profile.heritage.name} – {profile.heritage.description}
      </p>
      <p>
        <strong>Journey:</strong> {profile.journey.description} (Age Band: {profile.journey.ageBand})
      </p>
    </div>
  );
}

export default IdentityProfile;
