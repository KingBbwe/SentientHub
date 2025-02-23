import React, { useState } from 'react';
import { Actor, HttpAgent } from '@dfinity/agent';
import { idlFactory } from '../declarations/OtherCanisterIDs.did';

function ProfileManagement({ identity }) {
  const [profile, setProfile] = useState(null);
  const agent = new HttpAgent({ identity });
  const actor = Actor.createActor(idlFactory, {
    agent,
    canisterId: 'your-profile-canister-id',
  });

  const createProfile = async () => {
    try {
      const result = await actor.createCharacterProfile();
      setProfile(result);
    } catch (error) {
      console.error("Error creating profile:", error);
    }
  };

  return (
    <div className="p-4 border rounded">
      <h2>Profile Management</h2>
      {profile ? (
        <div>
          <p><strong>Profile ID:</strong> {profile.id}</p>
          <p><strong>Attributes:</strong> {JSON.stringify(profile.attributes)}</p>
        </div>
      ) : (
        <button onClick={createProfile} className="bg-green-500 px-4 py-2 rounded">
          Create Profile
        </button>
      )}
    </div>
  );
}

export default ProfileManagement;
