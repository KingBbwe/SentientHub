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
| 4 | `src/Progression.mo`, `Economy.mo`, `Dice.mo`, `Sentient.mo`; `Hub.mo` now stateful | Done. One ladder from the canon constants (20 Skulduggery -> Taint, 5 Taints -> Vice, 4 Vices -> Villainy level; 25 Grace -> a Grace, 4 -> Virtue, 5 -> Venerable level; 5 Feats -> Medal, 5 Medals -> Acquired Skillset slot, 5 Skillsets -> Venerable status). Rewards by join cell, caps, 2 FP spent = 1 Skulduggery, Grace cleansing. On-chain dice (`raw_rand`, rejection sampling). Per-principal state with `register`, `submitCheck`, `spendFate`, `cleanse`, `claimSkillset`, `awardFeat` (controllers only). Tests: Progression, Economy, Dice, Sentient (all pass). The legacy `main.mo` is no longer needed. |
| 5 | `src/Bank.mo`; Hub bank functions | Done for the accounting half. Crystals and in-game FUDDY convert to a FUDDY *claim*; withdrawals open *orders* a human custodian settles, then records (`recordSettlement`). The only ledger call is read-only `icrc1_fee`. `tests/BankTest.mo` (conservation: converted = claim + pending + settled). **No signing, minting, burning or transfer exists.** |

`main.mo` is now legacy: it is kept only as the source for stage 4 and is not part of the build.

## Notes for the next stage
- Randomness stays outside `Rules.mo` (explicit rolls). The canister will need an on-chain source (`raw_rand`) behind one function, replacing the `await _rollDie` calls.
- The JSON-to-Candid mapping of a Character file is a front-end job (missing `acquired` becomes `[]`; `lineage.type` maps to `type_`).

## Stage 4 interpretations (for ratification)
1. The draft had three conflicting progression designs. The ladder above (your canon-compliant constants) is used; the checkpoint tables, the 10/20/40/60/80/100 villainy thresholds and the 1-20 sub-levels were dropped.
2. Taints are permanent. Grace cleanses only the uncrystallised Skulduggery meter, 1 Grace per 1 Skulduggery (spent Grace never lowers the Virtue ladder, which counts total Grace earned).
3. Levels cap at 7 (Abyssal / Divine). Venerable level scales rewards: percent = clamp(DC x (10 + level) / 10, 20, 100).
4. Rewards by join cell: pass+Triumph = Triumph set + full quest prize; pass+Conflict = Conflict set + half the prize; any Disaster = Skulduggery 1 + Type-4 crystal; fail+Triumph/Conflict = nothing.
5. Crystals and in-game FUDDY are balance-capped (100/80/50/20, 20). The Grace cap of 3 is per grant (as a balance cap it would make 25 Grace unreachable).
6. Persistence is a snapshot taken in `preupgrade`; a trap during an unplanned upgrade would lose the interim state. Move to stable storage before holding real value.
7. `awardFeat` is controller-only until Stage 5 decides who may award Feats.

## Stage 5 interpretations and open items
1. Move 6 asked for real ICRC-1/2 calls. Your standing rule (no code may sign, mint or burn) wins: the bank never sends FUDDY. Enabling sends needs your explicit decision on custody (a canister-held reserve account, or a human-signed flow).
2. ALL rates are PLACEHOLDER (draft's 1/5/10/20, in-game FUDDY 1). The unit (token decimals) is UNVERIFIED: run `icrc1_metadata` on `oeogn-qaaaa-aaaam-acoyq-cai` from your Ubuntu VM and send the result.
3. Withdrawals are paused until a controller calls `refreshLedgerFee` (reads `icrc1_fee`). The fee comes out of the gross (net = gross - fee); amounts at or below the fee are refused. That is the token working as designed.
4. `setLedger` points the read-only fee call at a local-replica ledger for playtests.
5. Orders are an unbounded array and state is saved in `preupgrade`: fine for a playtest, not for production.
6. The old `CrystalBank` repo code is not ported; this replaces it as the specification's working form.
