import { useState } from "react";
import Header from "./components/Header";
import ProfileManagement from "./components/ProfileManagement";
import QuestManagement from "./components/QuestManagement";
import ResourceManagement from "./components/ResourceManagement";
import ProgressionTracking from "./components/ProgressionTracking";
import NarrativeMemory from "./components/NarrativeMemory";

const App = () => {
  const [identity, setIdentity] = useState(null);
  const [wallet, setWallet] = useState(null);

  return (
    <div className="min-h-screen bg-gray-100">
      <Header setIdentity={setIdentity} setWallet={setWallet} />
      <div className="container mx-auto p-4">
        {identity && (
          <>
            <ProfileManagement identity={identity} />
            <QuestManagement identity={identity} />
            <ResourceManagement identity={identity} />
            <ProgressionTracking identity={identity} />
            <NarrativeMemory identity={identity} />
          </>
        )}
      </div>
    </div>
  );
};

export default App;
