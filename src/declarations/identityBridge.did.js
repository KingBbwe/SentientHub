export const idlFactory = ({ IDL }) => {
  const IdentityData = IDL.Record({
    principal: IDL.Text,
    characterName: IDL.Text,
    personalityProfile: IDL.Text,
    coreTraits: IDL.Record({
      conscious: IDL.Text,
      unconscious: IDL.Text,
    }),
    heritage: IDL.Record({
      name: IDL.Text,
      description: IDL.Text,
      baseAttributes: IDL.Vec(IDL.Tuple(IDL.Text, IDL.Nat)),
      surplus: IDL.Nat,
    }),
    journey: IDL.Record({
      description: IDL.Text,
      ageBand: IDL.Text,
    }),
    createdAt: IDL.Int,
  });
  const Result = IDL.Variant({ ok: IDL.Text, err: IDL.Text });
  return IDL.Service({
    registerIdentity: IDL.Func([IdentityData], [Result], ['async']),
    getIdentity: IDL.Func([IDL.Text], [IDL.Opt(IdentityData)], ['query']),
    updateIdentity: IDL.Func([IdentityData], [Result], ['async']),
  });
};
export const init = ({ IDL }) => { return []; };
