export const idlFactory = ({ IDL }) => {
  return IDL.Service({
    // Define additional canister methods for narrative memory, progression, quests, resources, etc.
    getNarrativeMemory: IDL.Func([], [IDL.Vec(IDL.Record({ id: IDL.Nat, narrativeText: IDL.Text }))], ['query']),
    getVillainyProgress: IDL.Func([], [IDL.Record({ currentLevel: IDL.Nat })], ['query']),
    getVenerableProgress: IDL.Func([], [IDL.Record({ currentLevel: IDL.Nat })], ['query']),
    generateQuest: IDL.Func([], [IDL.Record({ id: IDL.Nat, description: IDL.Text })], ['async']),
    completeQuest: IDL.Func([IDL.Nat], [], ['async']),
    getResourceBalance: IDL.Func([], [IDL.Record({ crystals: IDL.Nat, inGameFuddy: IDL.Nat, gracePoints: IDL.Nat })], ['query']),
    createCharacterProfile: IDL.Func([], [IDL.Record({ id: IDL.Text, attributes: IDL.Vec(IDL.Tuple(IDL.Text, IDL.Nat)) })], ['async']),
  });
};
export const init = ({ IDL }) => { return []; };
