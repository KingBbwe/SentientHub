// Shared by gen-character-parity.js and gen-slice.js: renders a Character JSON object as a Motoko record literal.
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
module.exports = { lit, q };
