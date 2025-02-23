import React, { useState, useEffect } from 'react';
import { Actor, HttpAgent } from '@dfinity/agent';
import { idlFactory } from '../declarations/OtherCanisterIDs.did';

function ProgressionTracking({ identity }) {
  const [progression, setProgression] = useState({});
  const agent = new HttpAgent({ identity });
  const actor = Actor.createActor(idlFactory, {
    agent,
    canisterId: 'your-progression-canister-id',
  });

  useEffect(() => {
    async function fetchProgression() {
      try {
        const villainy = await actor.getVillainyProgress();
        const venerable = await actor.getVenerableProgress();
        setProgression({ villainy, venerable });
      } catch (error) {
        console.error("Error fetching progression:", error);
      }
    }
    if (identity) {
      fetchProgression();
    }
  }, [identity, actor]);

  return (
    <div className="p-4 border rounded">
      <h2>Progression Tracking</h2>
      <p><strong>Villainy Level:</strong> {progression.villainy?.currentLevel || "N/A"}</p>
      <p><strong>Venerable Level:</strong> {progression.venerable?.currentLevel || "N/A"}</p>
    </div>
  );
}

export default ProgressionTracking;
