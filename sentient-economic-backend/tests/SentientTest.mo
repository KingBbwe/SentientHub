import S "../src/Sentient";
import Rules "../src/Rules";
import Data "../src/Data";
import Debug "mo:base/Debug";
import Iter "mo:base/Iter";

func check(pass : Bool, tier : Rules.Tier, dc : Nat) : Rules.CheckResult {
  let i : Rules.Input = { cast = 1; roll = 1; die = 6; mod = 0; dc; modeDc = null; stepDown = false; pullRoll = 6; resistPull = false };
  { pass; tier; mode = #over; pulled = false; twilight = false; bolted = false; cast = 1; castAdj = 1; roll = 1; die = 6; declaredDie = 6;
    stepDownUsed = false; stepDownPenalty = 0; joinKey = ""; joinName = ""; revealedLine = null; input = i };
};
let prize = Data.questTemplates[0].rewards;

// a triumph pays Grace 1, Fate +2, a Type-1 crystal (scaled), plus the prize
let s0 = S.newState(3);
let (s1, r1) = S.settle(s0, check(true, #T, 40), prize);
assert s1.fate.fp == 3 + 2 + 10 and s1.moral.grace == 1 and s1.moral.totalGrace == 1 and s1.balance.type1 == 4 + 50 and s1.checks == 1 and r1.size() >= 3;
// a disaster pays Skulduggery 1 and a Type-4 crystal, and costs no Fate
let (s2, _) = S.settle(s0, check(false, #D, 40), prize);
assert s2.moral.skulduggery == 1 and s2.balance.type4 == 1 and s2.fate.fp == 3;
// a failed Conflict pays nothing but counts as a check
let (s3, r3) = S.settle(s0, check(false, #C, 40), prize);
assert r3.size() == 0 and s3.checks == 1 and s3.moral == s0.moral and s3.balance == s0.balance;
// 20 disasters crystallise one Taint
var s = s0; for (_ in Iter.range(1, 20)) { s := S.settle(s, check(false, #D, 40), prize).0 };
assert s.moral.taints == 1 and s.moral.skulduggery == 0 and s.balance.type4 == 20;
// Fate spending: the 2nd point spent costs 1 Skulduggery, cumulative
switch (S.spendFate(s0, 1)) { case (#ok(a, owed)) { assert owed == 0 and a.fate.fp == 2;
  switch (S.spendFate(a, 1)) { case (#ok(b, owed2)) { assert owed2 == 1 and b.moral.skulduggery == 1 and b.fate.fp == 1 }; case (#err _) { assert false } } }; case (#err _) { assert false } };
switch (S.spendFate(s0, 4)) { case (#err _) {}; case (#ok _) { assert false } };      // cannot overspend
// cleansing: Grace against the meter only
let (c1, n1) = S.cleanse(S.settle(s2, check(true, #T, 40), []).0, 5); assert n1 == 1 and c1.moral.skulduggery == 0 and c1.moral.grace == 0;
// Acquired Skillsets: slot-gated, once each, named only
switch (S.claimSkillset(s0, "Emotional Reading")) { case (#err _) {}; case (#ok _) { assert false } };            // no slot yet
var f = s0; for (_ in Iter.range(1, 25)) { f := S.awardFeat(f) };
assert S.standing(f).medals == 5 and S.standing(f).slotsFree == 1;
switch (S.claimSkillset(f, "Emotional Reading")) { case (#ok g) { assert g.held == ["Emotional Reading"] and S.standing(g).slotsFree == 0;
  switch (S.claimSkillset(g, "Emotional Reading")) { case (#err _) {}; case (#ok _) { assert false } };
  switch (S.claimSkillset(g, "Rapport Building")) { case (#err _) {}; case (#ok _) { assert false } } }; case (#err _) { assert false } };      // no second slot yet
switch (S.claimSkillset(f, "Lockpicking")) { case (#err _) {}; case (#ok _) { assert false } };                  // not an Acquired Skillset
assert not S.venerable(f);
Debug.print("SentientTest ok");
