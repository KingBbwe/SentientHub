import { Actor, HttpAgent } from '@dfinity/agent';
import { idlFactory as IdentityBridgeIDL } from '../declarations/IdentityBridge.did';

const IDENTITY_BRIDGE_CANISTER_ID = 'your-identity-bridge-canister-id';

const agent = new HttpAgent();

export const identityBridge = Actor.createActor(IdentityBridgeIDL, {
  agent,
  canisterId: IDENTITY_BRIDGE_CANISTER_ID,
});

export async function registerIdentity(identityData) {
  return await identityBridge.registerIdentity(identityData);
}

export async function getIdentity(principal) {
  return await identityBridge.getIdentity(principal);
}

export async function updateIdentity(identityData) {
  return await identityBridge.updateIdentity(identityData);
}
