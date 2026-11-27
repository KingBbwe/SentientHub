// Generates sentient-economic-backend/src/Skills.mo from identify-eweself/skills.js (the source of truth). Do not hand-edit Skills.mo.
// usage: IDENTIFY_EWESELF=../identify-eweself node gen-skills.js
const fs = require('fs'), path = require('path');
const dir = path.resolve(process.env.IDENTIFY_EWESELF || path.join(__dirname, '../../../identify-eweself'));
const S = require(path.join(dir, 'skills.js'));
const q = s => JSON.stringify(s), opt = v => v == null ? 'null' : '?' + q(v);
const n = S.CATALOGUE.length, ex = S.CATALOGUE.filter(s => s.source !== 'canon-list' && s.source !== 'rules-text').length;
let out = `/// The canonical skills catalogue (generated from identify-eweself/skills.js; do not hand-edit: regenerate with tools/mo-check/gen-skills.js).
/// ${n} skills: the commander's list (111), Artistry and Command from the rules text, and ${ex} codex additions (link "proposed"); plus Acquired Skillsets.
module {
  public type Skill = { name : Text; domain : ?Text; group : ?Text; attribute : Text; source : Text; link : Text };
  public let DEFAULT : Int = ${S.DEFAULT};
  public let ASSIGNED_COUNT : Nat = ${S.ASSIGNED_COUNT};

  public let catalogue : [Skill] = [
`;
out += S.CATALOGUE.map(s => `    { name = ${q(s.name)}; domain = ${opt(s.domain)}; group = ${opt(s.group)}; attribute = ${q(s.attribute)}; source = ${q(s.source)}; link = ${q(s.link)} }`).join(',\n') + '\n  ];\n\n';
out += `  /// Acquired Skillsets: earned in play, held at modifier 0.
  public let acquired : [Text] = [${S.ACQUIRED_NAMES.map(q).join(', ')}];

  public func isSkill(name : Text) : Bool {
    for (s in catalogue.values()) { if (s.name == name) return true };
    false;
  };

  public func isAcquired(name : Text) : Bool {
    for (n in acquired.values()) { if (n == name) return true };
    false;
  };
};
`;
fs.writeFileSync(path.resolve(__dirname, '../../sentient-economic-backend/src/Skills.mo'), out);
console.log('wrote Skills.mo with', n, 'skills');
