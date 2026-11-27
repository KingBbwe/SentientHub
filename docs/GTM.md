# GTM.md - The Chronicles of Auld Ewe (Move 8)

Documentation only. It states what is real, what is mocked, what a mainnet launch needs, and the milestones. It takes no position on the legal or regulatory status of the token.

## 1. Real vs mocked

| Piece | State | Evidence |
|---|---|---|
| Character creation (identify-eweself) | Real. Soul-pattern and core-trait rolls, 32-point allocation, 113 skills, Acquired Skillsets, `auld-ewe.character` v1 export. | 44 unit tests, page checks; merged. |
| Rules engine (Hex-Die) | Real. Canon engine in JS; ported to Motoko. | 2,255 JS-vs-Motoko parity checks. |
| Character validation in SentientHub | Real, identical to the JS validator. | 461 parity cases. |
| Progression and economy | Real as code; **rules are my interpretation** of thin canon (see COMPILE_REPAIR_STATUS, Stage 4). | Motoko tests. |
| On-chain dice | Written, compile-checked, statistically tested in the interpreter. **Not run on a replica.** | DiceTest. |
| CrystalBank | Accounting and withdrawal orders only. **Rates are placeholders; units unverified.** | BankTest, conservation. |
| FUDDY settlement | **Mocked.** No code sends, mints, burns or signs. A human custodian settles orders. | By design. |
| FUDDY mainnet canister facts (fee, decimals, cycles) | **UNVERIFIED.** Not reachable from the sandbox. | Needs `icrc1_metadata` from your VM. |
| Canister under `dfx` | **Not run.** Upgrade persistence, Candid round-trips untested. | No replica available. |
| Front-end to canister hand-off | **Not built.** Character moves as a JSON file. | Vertical slice. |
| Telegram token | Externalised from the repo but **still live and in public git history** until revoked. | See checklist. |

## 2. Mainnet checklist (nothing here is done)

Security first
1. Revoke the Telegram bot token at BotFather (production-phase priority 1) and rotate anything else that was ever committed. Confirm with the commander whether the committed `SECRET_KEY` is live; do not test it.
2. Decide history handling for the leaked values (the history is public).

Platform
3. Run the system under a local replica: `dfx start`, deploy the Hub, exercise `register`, `submitCheck` and the bank functions. Fix what breaks.
4. Replace the `preupgrade` snapshot with stable storage; bound the orders array; test an upgrade with live state.
5. Controller set: who can `awardFeat`, `setBankConfig`, `recordSettlement`. Prefer a small multisig or SNS-style control over one key.
6. Cycle top-up plan and monitoring for the Hub (and a floor alert); the FUDDY ledger's own cycles via `icrc_plus_cycles`.

Token and bank
7. Read `icrc1_metadata`, `icrc1_fee`, `icrc_plus_fee_info` from the live ledger; set the unit scale; then call `refreshLedgerFee`.
8. Price every rate (crystal to FUDDY, in-game FUDDY, caps, minimum withdrawal). They are placeholders.
9. Custody model for settlement: who holds the funding account, how orders are signed, how often, and the audit trail (`recordSettlement` log). Decide before any code that sends is written; that code does not exist and needs your explicit go-ahead.
10. Fee model: ledger transfer and burn fees reduce what recipients get; decide who bears them and say so in player-facing text.

Product
11. Resolve open rulings: Fate Point cap enforcement; `linkedSkill` for Acquired Skillsets; more Acquired Skillsets; who awards Legendary Feats.
12. Review hexagram 60's narrative text and the 76 assigned skill-attribute links.

## 3. Regulatory surface

A tradeable token attached to a game carries regulatory surface. The commander must take that question to a qualified human advisor (legal, and tax where relevant) before any mainnet integration, player-facing sale, exchange listing, or reward that can be converted to FUDDY. This document does not assess it and should not be read as doing so.

## 4. Milestones

1. **Local vertical slice.** Done in the interpreter (`tools/mo-check/run-slice.sh`). Remaining for the milestone: the same flow against a local replica, and a front-end hand-off.
2. **Closed playtest on local or test FUDDY.** Needs a test ledger (local replica), placeholder rates agreed with the table, a custodian role played by a person, and a bug log. No mainnet FUDDY.
3. **Mainnet integration decision.** Only after the advisor's view (section 3), the checklist items above, and your explicit decision on custody.
