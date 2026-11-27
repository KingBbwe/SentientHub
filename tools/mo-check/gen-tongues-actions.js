// Generates src/Tongues.mo (from identify-eweself/tongues.js) and src/Actions.mo (from hex-die/engine/actions.js). Do not hand-edit those.
// usage: IDENTIFY_EWESELF=../identify-eweself HEX_DIE=../hex-die node gen-tongues-actions.js
const fs = require('fs'), path = require('path');
const ie = path.resolve(process.env.IDENTIFY_EWESELF || path.join(__dirname, '../../../identify-eweself'));
const hd = path.resolve(process.env.HEX_DIE || path.join(__dirname, '../../../hex-die'));
const T = require(path.join(ie, 'tongues.js')), A = require(path.join(hd, 'engine/actions.js'));
const q = s => JSON.stringify(s), src = path.resolve(__dirname, '../../sentient-economic-backend/src');

let t = `/// The 20 Tongues (generated from identify-eweself/tongues.js; do not hand-edit: tools/mo-check/gen-tongues-actions.js).
module {
  public type Resonance = { #Virtuous; #Challenging; #Neutral };
  public type Master = { name : Text; text : Text; resetsOnDay : Bool };
  public type Tongue = { id : Nat; name : Text; tribe : Text; resonance : Resonance; tp : Nat; synergy : [Text]; master : Master };

  public let tongues : [Tongue] = [
${T.TONGUES.map(x => `    { id = ${x.id}; name = ${q(x.name)}; tribe = ${q(x.tribe)}; resonance = #${x.resonance}; tp = ${x.tp}; synergy = [${x.synergy.map(q).join(', ')}]; master = { name = ${q(x.masterAbility.name)}; text = ${q(x.masterAbility.text)}; resetsOnDay = ${x.masterAbility.resets === 'day'} } }`).join(',\n')}
  ];

  public func find(name : Text) : ?Tongue {
    for (x in tongues.values()) { if (x.name == name) return ?x };
    null;
  };
};
`;
fs.writeFileSync(path.join(src, 'Tongues.mo'), t);

const amt = a => { const p = A.parseAmount(a); return p.faces === 0 ? `#fixed ${p.n}` : `#dice (${p.n}, ${p.faces})`; };
const eff = x => `{ when = #${x.when}; target = #${x.target}; resource = #${x.resource}; dir = #${x.dir}; amount = ${amt(x.amount)}; condition = ${x.condition ? '?#' + x.condition : 'null'} }`;
const effs = l => '[' + l.map(eff).join(', ') + ']';
let a = `/// The Action Economy as data (generated from hex-die/engine/actions.js; do not hand-edit: tools/mo-check/gen-tongues-actions.js).
/// Canon dice only. Grace is never spent: where the source spent Grace the cost is Fate Points.
module {
  public type Phase = { #head; #melee; #armed };
  public type Side = { #offense; #defense };
  public type Kind = { #instinctual; #volitional; #synergistic };
  public type When = { #triumph; #conflict; #disaster; #always };
  public type Target = { #self; #foe; #allies };
  public type Resource = { #resilience; #disquiet; #skulduggery; #grace; #fate; #tp };
  public type Dir = { #gain; #lose };
  public type Cond = { #ganga; #doshi };
  public type Amount = { #fixed : Nat; #dice : (Nat, Nat) };
  public type Effect = { when : When; target : Target; resource : Resource; dir : Dir; amount : Amount; condition : ?Cond };
  public type Action = { id : Nat; name : Text; phase : Phase; side : Side; kind : Kind; effects : [Effect]; note : Text };
  public type Named = { name : Text; effects : [Effect]; note : Text };

  public let actions : [Action] = [
${A.ACTIONS.map(x => `    { id = ${x.id}; name = ${q(x.name)}; phase = #${x.phase}; side = #${x.side}; kind = #${x.kind}; effects = ${effs(x.effects)}; note = ${q(x.note)} }`).join(',\n')}
  ];

  public let states : [Named] = [
${A.STATES.map(x => `    { name = ${q(x.name)}; effects = ${effs(x.effects)}; note = ${q(x.note)} }`).join(',\n')}
  ];

  public let dishonor : [Named] = [
${A.DISHONOR.map(x => `    { name = ${q(x.name)}; effects = ${effs(x.effects)}; note = ${q(x.note)} }`).join(',\n')}
  ];

  public func find(id : Nat) : ?Action {
    if (id >= 1 and id <= actions.size()) { ?actions[id - 1] } else { null };
  };
};
`;
fs.writeFileSync(path.join(src, 'Actions.mo'), a);
console.log('wrote Tongues.mo (' + T.TONGUES.length + ') and Actions.mo (' + A.ACTIONS.length + ')');
