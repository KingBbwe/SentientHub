import { useState, useEffect } from "react";
import { Actor, HttpAgent } from "@dfinity/agent";
import { idlFactory } from "../../declarations/sentient_economic_interactions";

const ProgressionTracking = ({ identity }) => {
  const [progression, setProgression] = useState({});

  useEffect(() => {
    const fetchProgression = async () => {
      const agent = new HttpAgent({ identity });
      const actor = Actor.createActor(idlFactory, {
        agent,
        canisterId: "YOUR_CANISTER_ID",
      });
      const villainy = await actor.getVillainyProgress();
      const venerable = await actor.getVenerableProgress();
      setProgression({ villainy, venerable });
    };
    fetchProgression();
  }, [identity]);

  return (
    <div className="p-4 border rounded">
      <h2 className="text-xl mb-4">Progression Tracking</h2>
      <p>Villainy Level: {progression.villainy?.currentLevel}</p>
      <p>Venerable Level: {progression.venerable?.currentLevel}</p>
    </div>
  );
};

export default ProgressionTracking;
