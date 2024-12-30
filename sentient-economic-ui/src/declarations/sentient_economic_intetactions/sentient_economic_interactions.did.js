export const idlFactory = ({ IDL }) => {
  const ResourceBalance = IDL.Record({
    crystals: IDL.Nat,
    inGameFuddy: IDL.Nat,
    gracePoints: IDL.Nat,
  });
  const VillainyProgress = IDL.Record({
    currentLevel: IDL.Text,
  });
  const VenerableProgress = IDL.Record({
    currentLevel: IDL.Text,
  });
  const NarrativeFragment = IDL.Record({
    id: IDL.Nat,
    narrativeText: IDL.Text,
  });
  const DifficultyClass = IDL.Record({
    value: IDL.Nat,
    description: IDL.Text,
    moralComplexity: IDL.Nat,
  });
  const Quest = IDL.Record({
    id: IDL.Nat,
    name: IDL.Text,
    description: IDL.Text,
    difficultyClass: DifficultyClass,
    legendaryThreshold: IDL.Nat,
    hexagramId: IDL.Nat,
    hexagramTheme: IDL.Text,
    hexagramDescription: IDL.Text,
    potentialSkullduggery: IDL.Nat,
  });
  return IDL.Service({
    createCharacterProfile: IDL.Func([], [IDL.Variant({ ok: IDL.Text, err: IDL.Text })], []),
    generateQuest: IDL.Func([], [IDL.Variant({ ok: Quest, err: IDL.Text })], []),
    completeQuest: IDL.Func([IDL.Nat], [IDL.Variant({ ok: IDL.Text, err: IDL.Text })], []),
    getNarrativeMemory: IDL.Func([], [IDL.Vec(NarrativeFragment)], ['query']),
    getVillainyProgress: IDL.Func([], [VillainyProgress], ['query']),
    getVenerableProgress: IDL.Func([], [VenerableProgress], ['query']),
    getResourceBalance: IDL.Func([], [ResourceBalance], ['query']),
  });
};
export const init = ({ IDL }) => {
  return [];
};
