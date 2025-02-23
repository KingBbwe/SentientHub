import React, { useState, useEffect } from 'react';
import { Actor, HttpAgent } from '@dfinity/agent';
import { idlFactory } from '../declarations/OtherCanisterIDs.did';

function ResourceManagement({ identity }) {
  const [resources, setResources] = useState({});
  const agent = new HttpAgent({ identity });
  const actor = Actor.createActor(idlFactory, {
    agent,
    canisterId: 'your-resource-canister-id',
  });

  useEffect(() => {
    async function fetchResources() {
      try {
        const res = await actor.getResourceBalance();
        setResources(res);
      } catch (error) {
        console.error("Error fetching resource balance:", error);
      }
    }
    if (identity) {
      fetchResources();
    }
  }, [identity, actor]);

  return (
    <div className="p-4 border rounded">
      <h2>Resource Management</h2>
      <p><strong>Crystals:</strong> {resources.crystals || 0}</p>
      <p><strong>In-Game FUDDY:</strong> {resources.inGameFuddy || 0}</p>
      <p><strong>Grace Points:</strong> {resources.gracePoints || 0}</p>
    </div>
  );
}

export default ResourceManagement;
