import { useState, useEffect } from "react";
import { Actor, HttpAgent } from "@dfinity/agent";
import { idlFactory } from "../../declarations/sentient_economic_interactions";

const ResourceManagement = ({ identity }) => {
  const [resources, setResources] = useState({});

  useEffect(() => {
    const fetchResources = async () => {
      const agent = new HttpAgent({ identity });
      const actor = Actor.createActor(idlFactory, {
        agent,
        canisterId: "YOUR_CANISTER_ID",
      });
      const res = await actor.getResourceBalance();
      setResources(res);
    };
    fetchResources();
  }, [identity]);

  return (
    <div className="p-4 border rounded">
      <h2 className="text-xl mb-4">Resource Management</h2>
      <p>Crystals: {resources.crystals}</p>
      <p>FUDDY: {resources.inGameFuddy}</p>
      <p>Grace Points: {resources.gracePoints}</p>
    </div>
  );
};

export default ResourceManagement;
