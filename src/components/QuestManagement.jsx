import { useState } from "react";
import { Actor, HttpAgent } from "@dfinity/agent";
import { idlFactory } from "../../declarations/sentient_economic_interactions";

const QuestManagement = ({ identity }) => {
  const [quests, setQuests] = useState([]);

  const generateQuest = async () => {
    try {
      const agent = new HttpAgent({ identity });
      const actor = Actor.createActor(idlFactory, {
        agent,
        canisterId: "YOUR_CANISTER_ID",
      });
      const quest = await actor.generateQuest();
      setQuests([...quests, quest]);
    } catch (error) {
      console.error("Error generating quest:", error);
    }
  };

  const completeQuest = async (questId) => {
    try {
      const agent = new HttpAgent({ identity });
      const actor = Actor.createActor(idlFactory, {
        agent,
        canisterId: "YOUR_CANISTER_ID",
      });
      await actor.completeQuest(questId);
      alert("Quest completed successfully!");
    } catch (error) {
      console.error("Error completing quest:", error);
    }
  };

  return (
    <div className="p-4 border rounded">
      <h2 className="text-xl mb-4">Quest Management</h2>
      <button onClick={generateQuest} className="bg-blue-500 px-4 py-2 rounded mb-4">
        Generate Quest
      </button>
      <ul>
        {quests.map((quest) => (
          <li key={quest.id} className="mb-2">
            <p>{quest.description}</p>
            <button onClick={() => completeQuest(quest.id)} className="bg-green-500 px-4 py-2 rounded">
              Complete Quest
            </button>
          </li>
        ))}
      </ul>
    </div>
  );
};

export default QuestManagement;
