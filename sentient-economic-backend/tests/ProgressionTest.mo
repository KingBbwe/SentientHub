import P "../src/Progression";
import Debug "mo:base/Debug";
import Iter "mo:base/Iter";

// ladders at their boundaries
var m = P.newMoral();
m := P.addSkulduggery(m, 19); assert m.taints == 0 and m.skulduggery == 19;
m := P.addSkulduggery(m, 1);  assert m.taints == 1 and m.skulduggery == 0 and m.totalSkulduggery == 20;
m := P.addSkulduggery(m, 45); assert m.taints == 3 and m.skulduggery == 5 and m.totalSkulduggery == 65;
// taints are permanent: cleansing only reduces the meter, never taints
m := P.addGrace(m, 30);
let (m2, c) = P.cleanse(m, 100); assert c == 5 and m2.skulduggery == 0 and m2.taints == 3 and m2.grace == 25 and m2.totalGrace == 30;
let (m3, c3) = P.cleanse(P.addSkulduggery(P.newMoral(), 10), 10); assert c3 == 0 and m3.skulduggery == 10;   // no Grace, nothing cleansed
let (m4, c4) = P.cleanse(P.addGrace(P.addSkulduggery(P.newMoral(), 10), 4), 10); assert c4 == 4 and m4.skulduggery == 6 and m4.grace == 0;
// Fate Points: 2 FP = 1 Skulduggery, cumulative
assert P.skulduggeryForFate(0, 1) == 0; assert P.skulduggeryForFate(1, 2) == 1; assert P.skulduggeryForFate(0, 5) == 2; assert P.skulduggeryForFate(3, 4) == 1; assert P.skulduggeryForFate(4, 4) == 0;
// villainy: 20 -> taint, 5 taints -> vice, 4 vices -> level
let s400 = P.addSkulduggery(P.newMoral(), 399); assert P.villainyLevel(s400) == 0 and P.vices(s400) == 3;
let s400b = P.addSkulduggery(s400, 1); assert P.villainyLevel(s400b) == 1 and P.vices(s400b) == 4;
let huge = P.addSkulduggery(P.newMoral(), 100000); assert P.villainyLevel(huge) == P.MAX_LEVEL;     // capped at Abyssal
assert P.villainyNames[P.villainyLevel(huge)] == "Abyssal";
// virtue: 25 grace -> a Grace, 4 -> virtue, 5 virtues -> level
let g = P.addGrace(P.newMoral(), 24); assert P.graces(g) == 0;
let g2 = P.addGrace(g, 1); assert P.graces(g2) == 1;
let g500 = P.addGrace(P.newMoral(), 500); assert P.virtues(g500) == 5 and P.venerableLevel(g500) == 1;
assert P.venerableLevel(P.addGrace(P.newMoral(), 499)) == 0;
assert P.venerableNames[P.venerableLevel(P.addGrace(P.newMoral(), 100000))] == "Divine";
// spending Grace never lowers the ladder
let spent = (P.cleanse(P.addGrace(P.addSkulduggery(P.newMoral(), 19), 500), 19)).0; assert P.venerableLevel(spent) == 1;
// feats: 5 -> medal, 5 medals -> a skillset slot
assert P.medals(4) == 0 and P.medals(5) == 1 and P.skillSlots(24) == 0 and P.skillSlots(25) == 1 and P.skillSlots(125) == 5;
assert not P.isVenerable(4) and P.isVenerable(5);
// the ladders are monotone in the totals: a sweep
var lastV = 0; var lastG = 0; var t = P.newMoral();
for (i in Iter.range(0, 2999)) { t := P.addSkulduggery(P.addGrace(t, 1), 1); assert P.villainyLevel(t) >= lastV; assert P.venerableLevel(t) >= lastG; lastV := P.villainyLevel(t); lastG := P.venerableLevel(t); assert t.skulduggery < 20 };
Debug.print("ProgressionTest ok");
