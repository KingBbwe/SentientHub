import { useState, useEffect } from "react";
import { Actor, HttpAgent } from "@dfinity/agent";
import { idlFactory } from "../../declarations/sentient_economic_interactions";

const NarrativeMemory = ({ identity }) => {
  const [memory, setMemory] = useState([]);

  useEffect(() => {
    const fetchMemory = async () => {
      const agent = new HttpAgent({ identity });
      const actor = Actor.createActor(idlFactory, {
        agent,
        canisterId: "YOUR_CANISTER_ID",
      });
      const mem = await actor.getNarrativeMemory();
      setMemory(mem);
    };
    fetchMemory();
  }, [identity]);

  return (
    <div className="p-4 border rounded">
      <h2 className="text-xl mb-4">Narrative Memory</h2>
      <ul>
        {memory.map((fragment) => (
          <li key={fragment.id} className="mb-2">
            <p>{fragment.narrativeText}</p>
          </li>
        ))}
      </ul>
    </div>
  );
};

export default NarrativeMemory;
