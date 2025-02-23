
import { useState } from "react";
import { Actor, HttpAgent } from "@dfinity/agent";
import { idlFactory } from "../../declarations/sentient_economic_interactions";

const ProfileManagement = ({ identity }) => {
  const [profile, setProfile] = useState(null);

  const createProfile = async () => {
    try {
      const agent = new HttpAgent({ identity });
      const actor = Actor.createActor(idlFactory, {
        agent,
        canisterId: "YOUR_CANISTER_ID",
      });
      const result = await actor.createCharacterProfile();
      setProfile(result);
    } catch (error) {
      console.error("Error creating profile:", error);
    }
  };

  return (
    <div className="p-4 border rounded">
      <h2 className="text-xl mb-4">Profile Management</h2>
      {profile ? (
        <div>
          <p>Profile ID: {profile.id}</p>
          <p>Attributes: {JSON.stringify(profile.attributes)}</p>
        </div>
      ) : (
        <button onClick={createProfile} className="bg-green-500 px-4 py-2 rounded">
          Create Profile
        </button>
      )}
    </div>
  );
};

export default ProfileManagement;
