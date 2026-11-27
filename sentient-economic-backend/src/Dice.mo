/// Unbiased dice from a finite entropy source (the 32 random bytes of the management canister's raw_rand, wrapped in Random.Finite).
/// Rejection sampling: draw the fewest bits that cover n, retry when the value falls outside 0..n-1. Pure given the entropy, so
/// every result can be replayed from the blob. Returns null if the entropy runs out (a 256-bit blob makes that practically never).
import Random "mo:base/Random";
import Nat8 "mo:base/Nat8";

module {
  public type Rolls = { cast : Nat; roll : Nat; pull : Nat; line : Nat };

  func bitsFor(n : Nat) : Nat8 {
    var bits : Nat8 = 1;
    var cap : Nat = 2;
    while (cap < n) { cap *= 2; bits += 1 };
    bits;
  };

  /// Uniform 1..n (n >= 1). null when the entropy is exhausted.
  public func draw(f : Random.Finite, n : Nat) : ?Nat {
    if (n < 1) return null;
    if (n == 1) return ?1;
    let bits = bitsFor(n);
    loop {
      switch (f.range(bits)) {
        case null return null;
        case (?v) { if (v < n) return ?(v + 1) };
      };
    };
  };

  /// The four rolls one check needs: the hexagram cast (1-64), the agency die (1..effectiveDie), the Pull d6 and a d6 reserved for a line reveal.
  public func rolls(f : Random.Finite, effectiveDie : Nat) : ?Rolls {
    let cast = switch (draw(f, 64)) { case null return null; case (?v) v };
    let roll = switch (draw(f, effectiveDie)) { case null return null; case (?v) v };
    let pull = switch (draw(f, 6)) { case null return null; case (?v) v };
    let line = switch (draw(f, 6)) { case null return null; case (?v) v };
    ?{ cast; roll; pull; line };
  };
};
