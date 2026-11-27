import Dice "../src/Dice";
import Random "mo:base/Random";
import Blob "mo:base/Blob";
import Array "mo:base/Array";
import Nat8 "mo:base/Nat8";
import Nat32 "mo:base/Nat32";
import Iter "mo:base/Iter";
import Debug "mo:base/Debug";

func blobOf(bytes : [Nat8]) : Blob { Blob.fromArray(bytes) };
let zeros = blobOf(Array.freeze(Array.init<Nat8>(32, 0)));
let ones = blobOf(Array.freeze(Array.init<Nat8>(32, 255)));

// extremes: all-zero entropy gives the lowest face everywhere; all-one entropy gives the top of a power-of-two range
switch (Dice.rolls(Random.Finite(zeros), 6)) { case (?r) { assert r.cast == 1 and r.roll == 1 and r.pull == 1 and r.line == 1 }; case null { assert false } };
assert Dice.draw(Random.Finite(ones), 64) == ?64;
assert Dice.draw(Random.Finite(ones), 6) == null;      // 3 bits, 7 is always rejected: the entropy runs out rather than bias a face
assert Dice.draw(Random.Finite(zeros), 1) == ?1;
assert Dice.draw(Random.Finite(zeros), 0) == null;

// pseudo-random blobs: every face of every die appears, always in range, and counts are close to uniform
var seed : Nat32 = 20261127;
func next() : Nat8 { seed := seed *% 1664525 +% 1013904223; Nat8.fromNat(Nat32.toNat(seed >> 24)) };
func randomBlob() : Blob { blobOf(Array.tabulate<Nat8>(32, func(_) { next() })) };
for (die in [6, 8, 12, 20].values()) {
  let counts = Array.init<Nat>(die, 0);
  var n = 0;
  for (_ in Iter.range(0, 2999)) {
    switch (Dice.draw(Random.Finite(randomBlob()), die)) {
      case (?v) { assert v >= 1 and v <= die; counts[v - 1] += 1; n += 1 };
      case null {};
    };
  };
  assert n > 2800;      // exhaustion is rare
  let expected = n / die;
  for (c in counts.values()) { assert c * 100 > expected * 70 and c * 100 < expected * 130 };      // within 30% of uniform
};
// a full check's rolls are in range and the same blob always gives the same rolls
let b = randomBlob();
let r1 = Dice.rolls(Random.Finite(b), 12); let r2 = Dice.rolls(Random.Finite(b), 12);
assert r1 == r2;
switch (r1) { case (?r) { assert r.cast >= 1 and r.cast <= 64 and r.roll >= 1 and r.roll <= 12 and r.pull >= 1 and r.pull <= 6 and r.line >= 1 and r.line <= 6 }; case null {} };
Debug.print("DiceTest ok");
