import E "../src/Economy";
import Data "../src/Data";
import Debug "mo:base/Debug";
import Iter "mo:base/Iter";
import Array "mo:base/Array";

// scale: clamps to 20..100, rises with the venerable level
assert E.scalePct(1, 0) == 20;
assert E.scalePct(20, 0) == 20;
assert E.scalePct(40, 0) == 40;
assert E.scalePct(40, 5) == 60;
assert E.scalePct(64, 7) == 100;
assert E.scalePct(64, 0) == 64;
for (dc in Iter.range(1, 64)) { for (lv in Iter.range(0, 7)) { let s = E.scalePct(dc, lv); assert s >= 20 and s <= 100 } };

let prize = Data.questTemplates[0].rewards;

// the six join cells
let pt = E.rewardsFor(true, #T, 40, 0, prize);
assert pt.size() == 3 + prize.size();                                  // Triumph set + the full prize
assert pt[0].resourceType == #GracePoints and pt[0].amount == 1;
assert pt[1].resourceType == #Crystal(#Type1) and pt[1].amount == 4;     // 10 x 40%
assert pt[2].resourceType == #Fate and pt[2].amount == 2;
let pc = E.rewardsFor(true, #C, 40, 0, prize);
assert pc[0].resourceType == #Crystal(#Type2) and pc[0].amount == 2;     // 5 x 40%
assert pc[1].resourceType == #InGameFUDDY;
assert pc.size() >= 2;
let pd = E.rewardsFor(true, #D, 40, 0, prize);
assert pd.size() == 2 and pd[0].resourceType == #Skullduggery;
let fd = E.rewardsFor(false, #D, 40, 0, prize);
assert fd.size() == 2 and fd[0].resourceType == #Skullduggery;
assert E.rewardsFor(false, #T, 40, 0, prize).size() == 0;
assert E.rewardsFor(false, #C, 40, 0, prize).size() == 0;
// Conflict halves the prize (floor) and drops what rounds to nothing
let one = [{ resourceType = #Ovine; amount = 1; narrativeSignificance = "x" }];
let halved = E.rewardsFor(true, #C, 40, 0, one);
assert halved.size() == 2;    // the prize of 1 halves to 0 and is dropped
// Grace is capped per grant, not as a balance
assert E.capGrant({ resourceType = #GracePoints; amount = 10; narrativeSignificance = "x" }).amount == 3;
assert E.capGrant({ resourceType = #Fate; amount = 10; narrativeSignificance = "x" }).amount == 10;
// balance caps: crystals and in-game FUDDY stop at their max, others keep growing
var b = E.newBalance();
for (i in Iter.range(1, 30)) { b := E.applyToBalance(b, { resourceType = #Crystal(#Type4); amount = 1; narrativeSignificance = "x" }) };
assert b.type4 == 20;
b := E.applyToBalance(b, { resourceType = #Crystal(#Type1); amount = 500; narrativeSignificance = "x" }); assert b.type1 == 100;
b := E.applyToBalance(b, { resourceType = #InGameFUDDY; amount = 99; narrativeSignificance = "x" }); assert b.inGameFuddy == 20;
b := E.applyToBalance(b, { resourceType = #Legendary; amount = 500; narrativeSignificance = "x" }); assert b.legendary == 500;
let b2 = E.applyToBalance(b, { resourceType = #Fate; amount = 5; narrativeSignificance = "x" }); assert b2 == b;       // not a balance item
let b3 = E.applyToBalance(b, { resourceType = #GracePoints; amount = 5; narrativeSignificance = "x" }); assert b3 == b;
// every quest template is applicable without trapping
for (q in Data.questTemplates.vals()) { for (r in q.rewards.vals()) { ignore E.applyToBalance(E.newBalance(), E.capGrant(r)) } };
Debug.print("EconomyTest ok");
