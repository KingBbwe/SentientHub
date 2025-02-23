import React, { useState, useEffect } from 'react';
import { Actor, HttpAgent } from '@dfinity/agent';
import { idlFactory } from '../declarations/OtherCanisterIDs.did';

function NarrativeMemory({ identity }) {
  const [memory, setMemory] = useState([]);
  const agent = new HttpAgent({ identity });
  const actor = Actor.createActor(idlFactory, {
    agent,
    canisterId: 'your-narrative-canister-id',
  });

  useEffect(() => {
    async function fetchMemory() {
      try {
        const mem = await actor.getNarrativeMemory();
        setMemory(mem);
      } catch (error) {
        console.error("Error fetching narrative memory:", error);
      }
    }
    if (identity) {
      fetchMemory();
    }
  }, [identity, actor]);

  return (
    <div className="p-4 border rounded">
      <h2>Narrative Memory</h2>
      <ul>
        {memory.map(fragment => (
          <li key={fragment.id} className="mb-2">
            <p>{fragment.narrativeText}</p>
          </li>
        ))}
      </ul>
    </div>
  );
}

export default NarrativeMemory;
