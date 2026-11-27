import V "../src/Vitals";
import T "../src/Tongues";
import Debug "mo:base/Debug";

// Tongues data
assert T.tongues.size() == 20;
for (x in T.tongues.values()) { assert x.tp == 2 or x.tp == 3; assert x.synergy.size() >= 1 };
switch (T.find("Hope Tongue")) { case (?x) { assert x.tp == 2 and x.master.name == "Dawn's Promise" and not x.master.resetsOnDay }; case null { assert false } };
switch (T.find("Truth Tongue")) { case (?x) { assert x.tp == 3 and x.master.resetsOnDay }; case null { assert false } };
assert T.find("Nope") == null;

// Resilience: max from Will, caps, the broken flag
assert V.resilienceMaxFor(1) == 24 and V.resilienceMaxFor(5) == 40;
var v = V.newVitals(3, null);
assert v.resilience == 32 and v.resilienceMax == 32 and v.tp == V.TP_MAX and v.disquiet == 0 and not v.burnout and not v.masterUsed;
let (v1, b1) = V.loseResilience(v, 10); assert v1.resilience == 22 and not b1;
let (v2, b2) = V.loseResilience(v1, 100); assert v2.resilience == 0 and b2;
let (v3, b3) = V.loseResilience(v2, 5); assert v3.resilience == 0 and not b3;      // already at zero: not reported again
assert V.gainResilience(v1, 1000).resilience == 32;
// Disquiet: capped, floors at zero, one point is one penalty point
assert V.gainDisquiet(v, 4).disquiet == 4 and V.disquietPenalty(V.gainDisquiet(v, 4)) == 4;
assert V.gainDisquiet(v, 99).disquiet == V.DISQUIET_MAX;
assert V.loseDisquiet(V.gainDisquiet(v, 4), 9).disquiet == 0;
// Tongue Power: need a Tongue, enough TP, cost from the Tongue
switch (V.speak(v)) { case (#err _) {}; case (#ok _) { assert false } };               // no Tongue
let h = V.newVitals(3, ?"Hope Tongue");                                                    // cost 2
let c = V.newVitals(3, ?"Courage Tongue");                                                 // cost 3
switch (V.speak(h)) { case (#ok (h2, cost)) { assert cost == 2 and h2.tp == V.TP_MAX - 2 }; case (#err _) { assert false } };
switch (V.speak(c)) { case (#ok (c2, cost)) { assert cost == 3 and c2.tp == V.TP_MAX - 3 }; case (#err _) { assert false } };
switch (V.speak(V.loseTP(c, V.TP_MAX - 2))) { case (#err _) {}; case (#ok _) { assert false } };       // 2 TP left, needs 3
switch (V.speak({ h with tongue = ?"Bogus Tongue" })) { case (#err _) {}; case (#ok _) { assert false } };
// three speakings of a cost-2 Tongue empty the pool of 6; a fourth fails
var s = h; var n = 0;
label l loop { switch (V.speak(s)) { case (#ok (s2, _)) { s := s2; n += 1 }; case (#err _) { break l } } };
assert n == 3 and s.tp == 0;
// burnout only on a Disaster; master once per rest; a long rest resets everything
assert not V.afterSpeaking(h, #T).burnout and not V.afterSpeaking(h, #C).burnout and V.afterSpeaking(h, #D).burnout;
switch (V.useMaster(h)) { case (#ok (h2, m)) { assert h2.masterUsed and m.name == "Dawn's Promise"; switch (V.useMaster(h2)) { case (#err _) {}; case (#ok _) { assert false } } }; case (#err _) { assert false } };
switch (V.useMaster(v)) { case (#err _) {}; case (#ok _) { assert false } };
let worn = { V.afterSpeaking(V.gainDisquiet(h, 5), #D) with masterUsed = true; tp = 0; resilience = 1 };
let rested = V.longRest(worn);
assert rested.resilience == rested.resilienceMax and rested.disquiet == 0 and rested.tp == rested.tpMax and not rested.burnout and not rested.masterUsed and rested.tongue == ?"Hope Tongue";
Debug.print("VitalsTest ok");
