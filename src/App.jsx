import React, { useState } from 'react';
import { createActorWithIdentity } from './index.js';
import Header from './Header';
import ProfileManagement from './ProfileManagement';
import QuestManagement from './QuestManagement';
import ResourceManagement from './ResourceManagement';
import NarrativeMemory from './NarrativeMemory';
import ProgressionTracking from './ProgressionTracking';

function App() {
  const [identity, setIdentity] = useState(null);
  const [wallet, setWallet] = useState(null);

  return (
    <div className="bg-gray-100 min-h-screen">
      <Header setIdentity={setIdentity} setWallet={setWallet} />
      <div className="container mx-auto p-4">
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          <ProfileManagement identity={identity} />
          <QuestManagement identity={identity} />
          <ResourceManagement identity={identity} />
          <NarrativeMemory identity={identity} />
          <ProgressionTracking identity={identity} />
        </div>
      </div>
    </div>
  );
}

export default App;
