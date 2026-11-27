# main.mo compile repair: status (2026-11-27)

`sentient-economic-backend/main.mo` (about 2,550 lines) does not compile. It is several drafts pasted together, not one program.
Repair is verified with `tools/mo-check` (Motoko compiler via the `motoko` npm package; no dfx needed).

## Done on this branch (mechanical, content-preserving)
- 152 typographic quotes turned into ASCII quotes (the original cause of the first parse error).
- Arabic punctuation that had replaced `;` and `=` in quest 52.
- Narrative fragments: a JavaScript-style `n => {...}` table rewritten as a Motoko array indexed by hexagram number; the "We" typo on 61 removed; **hexagram 60 was missing and was written in the same voice (flag for review)**.
- Quests: 64 hand-edited rows with mixed layouts rebuilt as `questTemplates` (every id, text and reward parsed back out and counted: 64 quests, 128 rewards). The old array was unused by any function.
- `#Crystal.TypeN` corrected to `#Crystal(#TypeN)` (17 places); the `PersonalityProfile` type's missing brace.
- Age bands already aligned (merged earlier).

## Remaining (about 250 syntax errors, and the type errors behind them are not yet visible)
1. **Duplicated drafts.** 20 functions are defined two or three times (e.g. `calculateRewardScale` at three places with different arities; `generateTriumphRewards`, `rollDie`, `getOutcome`, `applyRewards`, `calculateVillainyLevel`...). One definition per name must be chosen.
2. **JavaScript/Rust idioms**: 24 record spreads (`{ ...profile }`), ternary `?:`, in-place `:=` on immutable record fields, `await` inside non-async functions (13 call sites of `_rollDie`).
3. **Rules drift.** SentientHub resolves rolls its own way (e.g. outcome by `dieRoll >= DC + 5`), which contradicts RULES_CANON (hexagram cast + die against a Personal DC, Roll-Over/Under bands, tier from the die). Repairing the code as written would compile a second, wrong rules engine.
4. **Character shape.** The actor's `PersonalityProfile` predates the `auld-ewe.character` v1 contract (four Personal DCs, 32-point allocation, skills, acquired skillsets).

## Recommended route
Do not patch line by line. Rebuild the actor in stages, each ending at zero compiler errors:
1. Data-only module: constants, tables, narrative fragments, quest templates (this branch has most of it).
2. Types matching `auld-ewe.character` v1 plus an import function that validates a Character like `character.js` does.
3. Rules module ported from `hexdie.js` (bands, signed agency, Pull, step-down, join table) with the same test vectors.
4. Economy and progression (resources, villainy and venerable tracks, feats, medals, acquired skills) on top, one function per name.
5. CrystalBank / FUDDY wiring (Move 6).
