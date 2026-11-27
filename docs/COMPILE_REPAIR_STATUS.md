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

## Rebuild progress (staged, each stage ends at zero compiler errors)
Run everything with `tools/mo-check/test-all.sh` (needs `npm i motoko` and `./fetch-base.sh` in that folder).

| Stage | Module | State |
|---|---|---|
| 1 | `src/Types.mo`, `src/Data.mo` | Done. Constants, 64 core traits, 64 journeys, 64 narrative fragments, 64 quest templates, 12 profiles, 2 age bands. `tests/DataTest.mo`. |
| 2 | `src/Skills.mo`, `src/Character.mo` | Done. `auld-ewe.character` v1 as a Candid record; `validate` returns the same error list as identify-eweself's JS validator on 461 generated cases (`tests/CharacterParity.mo`). |
| 3 | `src/Rules.mo` | Done. Port of `hexdie.js` (Signed Agency, Ovine Pull, Bolt, step-down on the cast, join table, line reveal, disaster mitigation, damage DCs). `tests/RulesParity.mo`: 2,255 checks, 500 reveals, 500 mitigations, 800 DC adjustments, 216 line keeps all equal to the JS engine; three deliberate rule changes were each caught. |
| 3 | `src/Hub.mo` | A small, compiling, read-only canister (validate a Character, resolve a check, serve narratives and quests); its Candid interface generates. |
| 4 | Economy and progression | Not started: resources, villainy and venerable tracks, feats, medals, acquired skills, storage. Port one function per name from `main.mo`, deleting the duplicates. |
| 5 | CrystalBank / FUDDY | Not started (Move 6). |

`main.mo` is now legacy: it is kept only as the source for stage 4 and is not part of the build.

## Notes for the next stage
- Randomness stays outside `Rules.mo` (explicit rolls). The canister will need an on-chain source (`raw_rand`) behind one function, replacing the `await _rollDie` calls.
- The JSON-to-Candid mapping of a Character file is a front-end job (missing `acquired` becomes `[]`; `lineage.type` maps to `type_`).
