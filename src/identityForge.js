// identityForge.js (client-side, using DFINITY agent)
import { Actor, HttpAgent } from '@dfinity/agent';
import { idlFactory as IdentityBridgeIDL } from './declarations/IdentityBridge.did';

const IDENTITY_BRIDGE_CANISTER_ID = 'your-identity-bridge-canister-id';

export async function submitIdentity(identityData) {
  const agent = new HttpAgent();
  const identityBridge = Actor.createActor(IdentityBridgeIDL, {
    agent,
    canisterId: IDENTITY_BRIDGE_CANISTER_ID,
  });
  const result = await identityBridge.registerIdentity(identityData);
  return result;
}
