// Generates sentient-economic-backend/tests/CharacterParity.mo: the same Characters, valid and mutated, run through the JS
// validator (identify-eweself/character.js) and expected to give identical error lists from Character.validate in Motoko.
// usage: IDENTIFY_EWESELF=../identify-eweself node gen-character-parity.js
const fs = require('fs'), path = require('path');
const dir = path.resolve(process.env.IDENTIFY_EWESELF || path.join(__dirname, '../../../identify-eweself'));
const C = require(path.join(dir, 'character.js'));
const base = JSON.parse(fs.readFileSync(path.join(dir, 'docs/example-character.json'), 'utf8'));
const q = s => JSON.stringify(s);
const ATTRS = ['Inspiration', 'Intellect', 'Prowess', 'SelfAwareness', 'Instinct', 'Drive', 'Energy', 'Emotion', 'Will'];
const attrs = a => '{ ' + ATTRS.map(k => k + ' = ' + a[k]).join('; ') + ' }';
const pair = p => '(' + p[0] + ', ' + p[1] + ')';
const kv = o => '[' + Object.keys(o).map(k => '(' + q(k) + ', ' + o[k] + ')').join(', ') + ']';
const dc = d => '{ value = ' + d.value + '; band = ' + q(d.band) + '; mode = #' + d.mode + '; source = ' + q(d.source) + ' }';
const end = e => '{ role = ' + q(e.role) + '; hexagram = ' + e.hexagram + '; name = ' + q(e.name) + ' }';
function lit(c) {
  const cr = c.creation;
  const crL = !cr ? 'null' : '?{ soulRoll = ' + (cr.soulRoll ? '?{ dice = ' + pair(cr.soulRoll.dice) + '; rerolls = [' + (cr.soulRoll.rerolls || []).join(', ') + '] }' : 'null') +
    '; traitRolls = ' + (cr.traitRolls ? '?{ conscious = ' + (cr.traitRolls.conscious ? '?' + pair(cr.traitRolls.conscious) : 'null') + '; unconscious = ' + (cr.traitRolls.unconscious ? '?' + pair(cr.traitRolls.unconscious) : 'null') + ' }' : 'null') +
    '; skillRoll = ' + (cr.skillRoll ? '?{ picks = [' + cr.skillRoll.picks.map(q).join(', ') + '] }' : 'null') + '; rollCount = ' + (cr.rollCount || 0) + '; penalty = ' + (cr.penalty || 0) + ' }';
  return `{ schema = ${q(c.schema)}; version = ${c.version}; id = ${q(c.id)}; createdAt = ${q(c.createdAt)}; name = ${q(c.name)}; gender = #${c.gender};
    nameHexagram = ${c.nameHexagram}; renamesRemaining = ${c.renamesRemaining};
    soul = { pattern = ${q(c.soul.pattern)}; profile = ${pair(c.soul.profile)}; profileId = ${q(c.soul.profileId)}; profileName = ${q(c.soul.profileName)} };
    coreTraits = { conscious = { trait = ${q(c.coreTraits.conscious.trait)}; hexagram = ${c.coreTraits.conscious.hexagram} }; unconscious = { trait = ${q(c.coreTraits.unconscious.trait)}; hexagram = ${c.coreTraits.unconscious.hexagram} } };
    trajectory = { id = ${c.trajectory.id}; ageBand = ${q(c.trajectory.ageBand)}; a = ${end(c.trajectory.a)}; b = ${end(c.trajectory.b)} };
    dc = { intellectual = ${dc(c.dc.intellectual)}; physical = ${dc(c.dc.physical)}; emotional = ${dc(c.dc.emotional)}; spiritual = ${dc(c.dc.spiritual)} };
    lineage = { name = ${q(c.lineage.name)}; type_ = ${q(c.lineage.type)}; role = ${q(c.lineage.role)}; traits = [${c.lineage.traits.map(q).join(', ')}] };
    tribe = { name = ${q(c.tribe.name)}; tongue = ${q(c.tribe.tongue)}; resonance = ${q(c.tribe.resonance)} };
    attributes = ${attrs(c.attributes)};
    allocation = { rule = ${q(c.allocation.rule)}; mode = #${c.allocation.mode}; budget = ${c.allocation.budget}; spent = ${c.allocation.spent}; remaining = ${c.allocation.remaining}; complete = ${c.allocation.complete}; rerollPenalty = ${c.allocation.rerollPenalty}; floors = ${attrs(c.allocation.floors)} };
    acquired = ${kv(c.acquired)}; skills = ${kv(c.skills)}; dieTier = ${c.dieTier}; skulduggery = ${c.skulduggery}; grace = ${c.grace}; creation = ${crL} }`;
}
// mutators: each keeps every field the right TYPE (so the Motoko record is well typed) but breaks a rule
const M = [
  c => { c.schema = 'other'; }, c => { c.version = 2; }, c => { c.id = ''; }, c => { c.name = ''; },
  c => { c.soul.profile = [2, 2]; }, c => { c.soul.profile = [6, 6]; }, c => { c.soul.profile = [4, 1]; c.creation.soulRoll = undefined; },
  c => { c.dc.intellectual.value = 0; }, c => { c.dc.physical.value = 65; }, c => { c.dc.emotional.value = 40; }, c => { c.dc.spiritual.value = 20; },
  c => { c.dc.intellectual.mode = c.dc.intellectual.mode === 'over' ? 'under' : 'over'; }, c => { c.dc.physical.mode = c.dc.physical.mode === 'over' ? 'under' : 'over'; },
  c => { c.dc.emotional.mode = c.dc.emotional.mode === 'over' ? 'under' : 'over'; }, c => { c.dc.spiritual.mode = 'under'; },
  c => { c.dieTier = 7; }, c => { c.dieTier = 12; }, c => { c.dieTier = 0; }, c => { c.trajectory.ageBand = '0-50'; }, c => { c.trajectory.ageBand = '36-50+'; },
  c => { c.attributes.Inspiration = 0; }, c => { c.attributes.Will = 6; }, c => { c.attributes.Drive = 5; }, c => { c.allocation.floors.Energy = 0; }, c => { c.allocation.floors.Prowess = 6; },
  c => { c.allocation.floors.Instinct = 5; }, c => { c.allocation.mode = 'free'; }, c => { c.allocation.mode = 'free'; c.allocation.floors = { Inspiration: 1, Intellect: 1, Prowess: 1, SelfAwareness: 1, Instinct: 1, Drive: 1, Energy: 1, Emotion: 1, Will: 1 }; },
  c => { c.allocation.spent = 30; }, c => { c.allocation.budget = 20; }, c => { c.allocation.budget = 40; }, c => { c.allocation.remaining = 0; }, c => { c.allocation.remaining = 9; },
  c => { c.allocation.complete = true; }, c => { c.allocation.rule = '33-point'; },
  c => { c.skills.Bogus = 0; }, c => { c.skills.Swordsmanship = -3; }, c => { c.skills.Swordsmanship = 2; }, c => { c.skills = {}; },
  c => { c.acquired = { 'Rapport Building': 0 }; }, c => { c.acquired = { Nope: 0 }; }, c => { c.acquired = { 'Emotional Reading': 0, 'Rapport Building': 0 }; },
  c => { c.creation.soulRoll.dice = [2, 3]; }, c => { c.creation.soulRoll.rerolls = []; }, c => { c.creation.soulRoll.rerolls = [2, 3, 6]; }, c => { c.creation.soulRoll.rerolls = [3, 6, 3]; },
  c => { c.creation.soulRoll.rerolls = [2, 6, 4]; }, c => { c.creation.soulRoll = undefined; }, c => { c.creation.traitRolls.conscious = [2, 5]; }, c => { c.creation.traitRolls.unconscious = [1, 1]; },
  c => { c.creation.traitRolls.conscious = undefined; }, c => { c.creation.traitRolls = undefined; },
  c => { c.creation.skillRoll.picks = ['Swordsmanship', 'Swordsmanship']; }, c => { c.creation.skillRoll.picks = ['Command']; }, c => { c.creation.skillRoll = undefined; }, c => { c.creation = undefined; },
  c => { c.coreTraits.conscious.hexagram = 6; }, c => { c.coreTraits.unconscious.hexagram = 21; }, c => { c.trajectory.a.hexagram = 14; }, c => { c.trajectory.b.hexagram = 8; }
];
let seed = 20261127; const rnd = () => ((seed = (Math.imul(seed, 1664525) + 1013904223) >>> 0) / 4294967296);
const cases = [JSON.parse(JSON.stringify(base))];
M.forEach(m => { const c = JSON.parse(JSON.stringify(base)); m(c); cases.push(c); });
for (let i = 0; i < 400; i++) { const c = JSON.parse(JSON.stringify(base)); const k = 2 + Math.floor(rnd() * 3); for (let j = 0; j < k; j++) { try { M[Math.floor(rnd() * M.length)](c); } catch (e) { /* mutator needs a field a previous one removed */ } } cases.push(c); }
let out = '// GENERATED by tools/mo-check/gen-character-parity.js from identify-eweself/character.js. Do not hand-edit.\n// Each case: a Character and the exact error list the JS validator gives; Motoko must give the same list.\nimport Character "../src/Character";\nimport Debug "mo:base/Debug";\nimport Array "mo:base/Array";\n\nlet cases : [(Character.Character, [Text])] = [\n';
let nOk = 0, nBad = 0;
out += cases.map(c => { const v = C.validateCharacter(c); v.ok ? nOk++ : nBad++; return '  (' + lit(c) + ',\n   [' + v.errors.map(q).join(', ') + '])'; }).join(',\n');
out += '\n];\n\nvar failures = 0;\nfor (i in cases.keys()) {\n  let (c, expected) = cases[i];\n  let got = Character.validate(c);\n  if (got != expected) {\n    failures += 1;\n    Debug.print("MISMATCH case " # debug_show i # "\\n  expected " # debug_show expected # "\\n  got      " # debug_show got);\n  };\n};\nassert failures == 0;\nDebug.print("CharacterParity ok: " # debug_show cases.size() # " cases (' + nOk + ' valid, ' + nBad + ' invalid)");\n';
fs.writeFileSync(path.resolve(__dirname, '../../sentient-economic-backend/tests/CharacterParity.mo'), out);
console.log('cases', cases.length, 'valid', nOk, 'invalid', nBad);
