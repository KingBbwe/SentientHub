import React, { useState } from 'react';
import UpdateHeader from './UpdateHeader';
import IdentityProfile from './IdentityProfile';
import NarrativeMemory from './NarrativeMemory';
import ProgressionTracking from './ProgressionTracking';
import QuestManagement from './QuestManagement';
import ResourceManagement from './ResourceManagement';
import ProfileManagement from './ProfileManagement';

function Dashboard() {
  const [identity, setIdentity] = useState(null);
  const [wallet, setWallet] = useState(null);

  // For this example, assume identity is passed down from Login or set here.
  // In a complete app, identity would be stored in global state (e.g., Context or Redux).

  return (
    <div>
      <UpdateHeader setIdentity={setIdentity} setWallet={setWallet} />
      <div className="container">
        <h1>Dashboard</h1>
        <IdentityProfile identity={identity} />
        <ResourceManagement identity={identity} />
        <NarrativeMemory identity={identity} />
        <ProgressionTracking identity={identity} />
        <QuestManagement identity={identity} />
        <ProfileManagement identity={identity} />
      </div>
    </div>
  );
}

export default Dashboard;
