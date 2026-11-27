# Vertical slice (Move 7)

One command, from a clean checkout (identify-eweself checked out beside this repo):

    cd tools/mo-check && ./fetch-base.sh && ./run-slice.sh

It prints eleven numbered steps and `SLICE OK`:

1. A Character produced by identify-eweself (`docs/example-character.json`) is rendered as a Candid record and passes `Character.validate`.
2. A Sentient is registered (3 Fate Points, the table convention).
3. A quest carries the Character's physical Personal DC (20, roll-under).
4. Hex-Die resolves a check on dice drawn by `Dice.rolls` from a fixed entropy blob (the canister draws the same way from `raw_rand`).
5. A Grace-point line reveal improves the result.
6. One damage line (L6) shifts the DC (20 -> 19).
7. The final join cell pays rewards into the Sentient (FP 3 -> 8, crystals).
8. Spending 2 Fate Points costs 1 Skulduggery.
9. Crystals convert to a FUDDY claim at placeholder rates.
10. A withdrawal order is opened (fee out of the gross).
11. The custodian's settlement is recorded; the books balance.

## What this proves, and what it does not
- Proven: the data contract, rules, economy and bank compose correctly, in Motoko, deterministically.
- NOT proven (UNVERIFIED, no replica in the sandbox): the canister running under `dfx start`, `raw_rand` and `canister_status` calls, Candid round-trips, upgrade persistence.
- The handoff between apps is a file (the Character JSON), not a network call. A browser front-end that posts the JSON to the canister is not built.
- No FUDDY moves: the settlement is a recorded custodian outcome with a placeholder txid. The fee (1) is a stand-in.

## Finding for you
RULES_CANON lists a Fate Point cap of 5, but nothing in the code enforces it: the slice shows FP 3 -> 8. Say whether the cap is a rule (I will enforce it in `Sentient.settle`) or a table convention (leave as is).
