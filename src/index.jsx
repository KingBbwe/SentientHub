import { createActor } from './sentient_economic_interactions.did.js';
import { canisterId } from './env.js';

export const actor = createActor(canisterId, {
  agentOptions: {
    host: process.env.NEXT_PUBLIC_IC_HOST,
  },
});

export const createActorWithIdentity = (identity) => {
  return createActor(canisterId, {
    agentOptions: {
      identity,
      host: process.env.NEXT_PUBLIC_IC_HOST,
    },
  });
};
