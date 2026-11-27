import E "../src/Effects";
import A "../src/Actions";
import S "../src/Sentient";
import Progression "../src/Progression";
import Rules "../src/Rules";
import Random "mo:base/Random";
import Blob "mo:base/Blob";
import Array "mo:base/Array";
import Nat8 "mo:base/Nat8";
import Nat32 "mo:base/Nat32";
import Debug "mo:base/Debug";

func blobFor(seed : Nat) : Blob {
  var x : Nat32 = Nat32.fromNat(seed);
  Blob.fromArray(Array.tabulate<Nat8>(32, func(_) { x := x *% 1664525 +% 1013904223; Nat8.fromNat(Nat32.toNat(x >> 24)) }));
};
func fin(seed : Nat) : Random.Finite { Random.Finite(blobFor(seed)) };
func byName(n : Text) : A.Action { for (a in A.actions.values()) { if (a.name == n) return a }; assert false; loop {} };
func run(s : S.State, n : Text, tier : Rules.Tier, path : E.Path, seed : Nat) : E.Outcome {
  switch (E.perform(s, byName(n).effects, tier, path, fin(seed))) { case (#ok o) o; case (#err e) { Debug.print("unexpected: " # e); assert false; loop {} } };
};
func has(o : E.Outcome, r : A.Resource, d : A.Dir) : Bool { for (a in o.applied.values()) { if (a.resource == r and a.dir == d) return true }; false };

// the table itself: 60 actions, ids in order, canon dice only
assert A.actions.size() == 60;
for (a in A.actions.values()) { for (e in a.effects.values()) { switch (e.amount) { case (#dice (_, f)) { assert f == 6 or f == 8 or f == 12 or f == 20 }; case (#fixed n) { assert n > 0 } } } };
for (i in A.actions.keys()) { assert A.actions[i].id == i + 1 };

let base = S.newState(5);

// Skulduggery gains: Ovine Fury +5 on any tier; Final Stand +10 crystallises half a Taint ladder
for (t in [#T, #C, #D].values()) { let o = run(base, "Ovine Fury", t, #none, 1); assert o.state.moral.skulduggery == 5 };
let ff = run(base, "Final Stand", #C, #none, 1); assert ff.state.moral.skulduggery == 10;
let ff2 = run(ff.state, "Final Stand", #C, #none, 2); assert ff2.state.moral.taints == 1 and ff2.state.moral.skulduggery == 0;
// Skulduggery sinks: only the meter, never Taints
let tainted = { base with moral = Progression.addSkulduggery(Progression.newMoral(), 45) };           // 2 taints, 5 on the meter
let pl = run(tainted, "Purifying Light", #T, #none, 3); assert pl.state.moral.taints == 2 and pl.state.moral.skulduggery == 0;
let hy = run({ base with moral = Progression.addSkulduggery(Progression.newMoral(), 9) }, "Honorable Yield", #T, #none, 1); assert hy.state.moral.skulduggery == 6;
// Grace gains
assert run(base, "Yield Gracefully", #C, #none, 1).state.moral.grace == 2;
assert run(base, "Sacred Concession", #C, #none, 1).state.moral.grace == 3;
assert run(base, "Earthroot", #T, #none, 1).state.moral.grace == 1 and run(base, "Earthroot", #C, #none, 1).state.moral.grace == 0;
// Path conditions: Ganga-only Grace, Doshi-only Skulduggery
assert run(base, "Ward of Grace", #C, #ganga, 1).state.moral.grace == 2;
assert run(base, "Ward of Grace", #C, #none, 1).state.moral.grace == 0 and run(base, "Ward of Grace", #C, #doshi, 1).state.moral.grace == 0;
assert run(base, "Magical Barrage", #C, #doshi, 1).state.moral.skulduggery == 2 and run(base, "Magical Barrage", #C, #ganga, 1).state.moral.skulduggery == 0;
// Tier gating and foe-directed effects come back as Outgoing, not applied to the actor
let hlT = run(base, "Horn Lock", #T, #none, 4); assert hlT.outgoing.size() == 1 and hlT.outgoing[0].target == #foe and hlT.outgoing[0].amount >= 1 and hlT.outgoing[0].amount <= 6 and hlT.state == base;
let hlC = run(base, "Horn Lock", #C, #none, 4); assert hlC.outgoing.size() == 1 and hlC.outgoing[0].amount == 1 and hlC.state.vitals.resilience == base.vitals.resilience - 1;
let hlD = run(base, "Horn Lock", #D, #none, 4); assert hlD.outgoing.size() == 0 and hlD.state.vitals.disquiet == 1;
// Fate Point costs: paid first, all or nothing, and they accrue Skulduggery (2 spent = 1)
let broke = S.newState(0);
let hurt = { base with vitals = { base.vitals with resilience = 10 } };
switch (E.perform({ hurt with fate = { hurt.fate with fp = 0 } }, byName("Resilience Surge").effects, #T, #none, fin(1))) { case (#err _) {}; case (#ok _) { assert false } };
let rs = run(hurt, "Resilience Surge", #T, #none, 1); assert rs.state.fate.fp == 4 and rs.state.vitals.resilience > 10 and rs.state.vitals.resilience <= 16;
let sv = run(base, "Sanctuary Veil", #T, #none, 1); assert sv.state.fate.fp == 2 and sv.state.moral.skulduggery == 1 and sv.state.fate.spent == 3;
switch (E.perform(S.newState(2), byName("Sanctuary Veil").effects, #T, #none, fin(1))) { case (#err _) {}; case (#ok _) { assert false } };   // 2 FP < 3
// the broken flag: Lockbreaker Disaster takes 2 Resilience
let nearly = { base with vitals = { base.vitals with resilience = 2 } };
let lb = run(nearly, "Lockbreaker", #D, #none, 1); assert lb.state.vitals.resilience == 0 and lb.resilienceBroken;
// dice: Skyrend Strike 10d12 stays in 10..120 over many seeds and is not constant
var lo = 1000; var hi = 0;
for (seed in [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20].values()) {
  let o = run(base, "Skyrend Strike", #T, #none, seed);
  assert o.outgoing.size() == 1; let a = o.outgoing[0].amount; assert a >= 10 and a <= 120; if (a < lo) { lo := a }; if (a > hi) { hi := a };
};
assert hi > lo;
// entropy exhaustion is an error, not a trap
switch (E.perform(base, byName("Skyrend Strike").effects, #T, #none, Random.Finite(Blob.fromArray([])))) { case (#err _) {}; case (#ok _) { assert false } };
// every action x every tier x every path performs without trapping on a rich state
let rich = { base with fate = { base.fate with fp = 50 } };
for (a in A.actions.values()) { for (t in [#T, #C, #D].values()) { for (p in [#none, #ganga, #doshi].values()) { switch (E.perform(rich, a.effects, t, p, fin(a.id))) { case (#ok _) {}; case (#err e) { Debug.print(a.name # ": " # e); assert false } } } } };
// inflicted effects: no Fate Point accrual for the victim
let inflicted = switch (E.inflict(base, #fate, #lose, 4)) { case (#ok s) s; case (#err _) { assert false; loop {} } };
assert inflicted.fate.fp == 1 and inflicted.moral.skulduggery == 0;
Debug.print("EffectsTest ok");
