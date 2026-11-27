/// Harmonized Hex & Die resolution for SentientHub: a faithful port of hex-die/engine/hexdie.js (RULES_CANON rulings 1-5, G2b).
/// Pure functions with explicit rolls: randomness is supplied by the caller (the canister draws it elsewhere), so every
/// result can be replayed and compared with the JavaScript engine (see tests/RulesParity.mo, generated from the JS side).
/// Where hexdie.js throws a RangeError, these return #err with the same message.
import Result "mo:base/Result";
import Int "mo:base/Int";
import Nat "mo:base/Nat";
import Array "mo:base/Array";

module {
  public type Mode = { #over; #under };
  public type Tier = { #T; #C; #D };

  /// cast 1-64, roll 1..(effective die), die declared (6, 8, 12, 20), mod signed, dc 1-64.
  /// modeDc: the DC used to pick the band (pass the BASE dc when dc was shifted by damage). stepDown is GM-invoked only.
  public type Input = { cast : Nat; roll : Nat; die : Nat; mod : Int; dc : Nat; modeDc : ?Nat; stepDown : Bool; pullRoll : Nat; resistPull : Bool };

  public type CheckResult = {
    pass : Bool; tier : Tier; mode : Mode; pulled : Bool; twilight : Bool; bolted : Bool;
    cast : Nat; castAdj : Nat; roll : Nat; die : Nat; declaredDie : Nat;
    stepDownUsed : Bool; stepDownPenalty : Nat;
    joinKey : Text; joinName : Text; revealedLine : ?Nat; input : Input;
  };

  public type Fate = { fp : Nat; spent : Nat; sceneMitigation : Nat };

  // ---- CONFIG (all rules are data) ----
  /// Roll-Over / Roll-Under fixed by Personal-DC band (canon ruling 4): 1-16 over, 17-32 under, 33-48 over, 49-64 under.
  let bands : [(Nat, Nat, Mode)] = [(1, 16, #over), (17, 32, #under), (33, 48, #over), (49, 64, #under)];
  /// Ovine Pull: distance 1 from a band edge flips on d6 1-2, distance 2 on 1.
  let pullMax : Nat = 2;
  /// Outcome tier from the die alone: minimum roll for Triumph, then for Conflict.
  func tierTable(die : Nat) : ?(Nat, Nat) {
    switch (die) { case 6 ?(6, 4); case 8 ?(7, 4); case 12 ?(10, 5); case 20 ?(16, 10); case _ null };
  };
  /// Step-down (GM-invoked only): die -> (new die, penalty on the cast).
  func stepTable(die : Nat) : ?(Nat, Nat) {
    switch (die) { case 6 ?(6, 2); case 8 ?(6, 4); case 12 ?(8, 8); case 20 ?(12, 10); case _ null };
  };
  let skulduggeryPer : Nat = 2;
  let mitigationCapPerScene : Nat = 2;
  let dcDamageThreshold : [Nat] = [6, 5, 4, 3, 2, 1]; // for damage lines of level 1..6

  func lineTier(line : Nat) : ?Tier {
    switch (line) { case 1 ?#D; case 2 ?#D; case 3 ?#D; case 4 ?#C; case 5 ?#C; case 6 ?#T; case _ null };
  };
  func rank(t : Tier) : Nat { switch (t) { case (#D) 0; case (#C) 1; case (#T) 2 } };
  func tierKey(t : Tier) : Text { switch (t) { case (#T) "T"; case (#C) "C"; case (#D) "D" } };

  /// THE JOIN (approved): DC pass/fail x outcome tier.
  public func joinName(pass : Bool, tier : Tier) : Text {
    switch (pass, tier) {
      case (true, #T) "Green Pasture";
      case (true, #C) "Hard-Won Ground";
      case (true, #D) "The Wolf's Bargain";
      case (false, #T) "The Noble Stumble";
      case (false, #C) "Slipped Hold";
      case (false, #D) "The Cliff Edge";
    };
  };
  func joinKeyOf(pass : Bool, tier : Tier) : Text { (if pass "pass:" else "fail:") # tierKey(tier) };

  // ---- helpers ----
  func bandIndex(dc : Nat) : Result.Result<Nat, Text> {
    for (i in bands.keys()) { if (dc >= bands[i].0 and dc <= bands[i].1) return #ok i };
    #err("Personal DC out of range 1-64: " # Nat.toText(dc));
  };

  public func modeForDC(dc : Nat) : Result.Result<Mode, Text> {
    switch (bandIndex(dc)) { case (#err e) #err e; case (#ok i) #ok(bands[i].2) };
  };

  /// A Twilight DC (within pullMax of a band edge): distance from that edge and the neighbouring band's mode.
  public func twilight(dc : Nat) : Result.Result<?{ distance : Nat; neighbourMode : Mode }, Text> {
    switch (bandIndex(dc)) {
      case (#err e) #err e;
      case (#ok i) {
        let b = bands[i];
        let toTop = Int.abs((b.1 : Int) + 1 - dc);     // b.to - dc + 1 (>= 1: dc lies inside the band)
        let toBottom = Int.abs((dc : Int) + 1 - b.0);  // dc - b.from + 1 (>= 1)
        if (i + 1 < bands.size() and toTop <= pullMax) { #ok(?{ distance = toTop; neighbourMode = bands[i + 1].2 }) }
        else if (i > 0 and toBottom <= pullMax) { #ok(?{ distance = toBottom; neighbourMode = bands[i - 1].2 }) }
        else { #ok null };
      };
    };
  };

  public func tierFromRoll(die : Nat, roll : Nat) : Result.Result<Tier, Text> {
    switch (tierTable(die)) {
      case null #err("Unsupported die: d" # Nat.toText(die) # " (canon dice are d6, d8, d12, d20)");
      case (?(t, c)) { #ok(if (roll >= t) #T else if (roll >= c) #C else #D) };
    };
  };

  public func effectiveDie(die : Nat, stepDown : Bool) : Result.Result<(Nat, Nat), Text> {
    if (not stepDown) return #ok(die, 0);
    switch (stepTable(die)) { case null #err("No step-down defined for d" # Nat.toText(die)); case (?s) #ok s };
  };

  func pullFaces(distance : Nat) : [Nat] { if (distance == 1) [1, 2] else if (distance == 2) [1] else [] };
  func contains(xs : [Nat], x : Nat) : Bool { for (y in xs.values()) { if (y == x) return true }; false };

  // ---- the check ----
  public func resolveCheck(input : Input) : Result.Result<CheckResult, Text> {
    let eff = switch (effectiveDie(input.die, input.stepDown)) { case (#err e) return #err e; case (#ok v) v };
    let (effDie, penalty) = eff;
    if (not (input.roll >= 1 and input.roll <= effDie)) return #err("roll " # Nat.toText(input.roll) # " not on a d" # Nat.toText(effDie));
    let modeDc = switch (input.modeDc) { case null input.dc; case (?m) m };
    var mode = switch (modeForDC(modeDc)) { case (#err e) return #err e; case (#ok m) m };
    var pulled = false;
    let tw = switch (twilight(modeDc)) { case (#err e) return #err e; case (#ok t) t };
    switch (tw) {
      case null {};
      case (?t) {
        if (contains(pullFaces(t.distance), input.pullRoll) and not false) { mode := t.neighbourMode; pulled := true };
      };
    };
    let bolted = input.roll == 1;
    let push : Int = if bolted { -(effDie : Int) } else { input.roll };
    let castI : Int = input.cast;
    let castAdj : Int = switch (mode) {
      case (#over) { Int.max(1, castI - penalty) };
      case (#under) { Int.min(64, castI + penalty) };
    };
    let dcI : Int = input.dc;
    let pass = switch (mode) {
      case (#over) { castAdj + push + input.mod >= dcI };
      case (#under) { castAdj <= dcI + push + input.mod };
    };
    let tier = switch (tierFromRoll(effDie, input.roll)) { case (#err e) return #err e; case (#ok t) t };
    #ok {
      pass; tier; mode; pulled; twilight = tw != null; bolted;
      cast = input.cast; castAdj = Int.abs(castAdj); roll = input.roll; die = effDie; declaredDie = input.die;
      stepDownUsed = input.stepDown; stepDownPenalty = penalty;
      joinKey = joinKeyOf(pass, tier); joinName = joinName(pass, tier); revealedLine = null; input;
    };
  };

  // ---- Fate Points (canon ruling 1) ----
  public func newFate(points : Nat) : Fate { { fp = points; spent = 0; sceneMitigation = 0 } };
  public func skulduggeryFromFate(f : Fate) : Nat { f.spent / skulduggeryPer };
  public func spendFate(f : Fate, n : Nat) : Result.Result<Fate, Text> {
    if (f.fp < n) return #err "Not enough Fate Points";
    #ok { fp = f.fp - n; spent = f.spent + n; sceneMitigation = f.sceneMitigation };
  };
  public func newScene(f : Fate) : Fate { { fp = f.fp; spent = f.spent; sceneMitigation = 0 } };

  func withRoll(i : Input, roll : Nat) : Input { { i with roll } };

  /// Reveal a hexagram line (1-6): substitute the die result ONLY if the line beats the roll AND the tier improves. A natural-1
  /// bolt is mastered when substituted. Returns the (possibly unchanged) result and whether it applied.
  public func revealLine(r : CheckResult, line : Nat) : Result.Result<(CheckResult, Bool), Text> {
    let lt = switch (lineTier(line)) { case null return #err "line must be 1-6"; case (?t) t };
    if (not (line > r.roll) or rank(lt) <= rank(r.tier)) return #ok(r, false);
    switch (resolveCheck(withRoll(r.input, line))) {
      case (#err e) #err e;
      case (#ok re) {
        #ok({ re with tier = lt; joinName = joinName(re.pass, lt); joinKey = joinKeyOf(re.pass, lt); revealedLine = ?line }, true);
      };
    };
  };

  /// +1 per Fate Point to a DISASTER roll, at most 2 per scene. points 0 counts as 1 (as in hexdie.js). Returns (result, fate, used).
  public func mitigateDisaster(r : CheckResult, fate : Fate, points : Nat) : Result.Result<(CheckResult, Fate, Nat), Text> {
    let want : Int = if (points == 0) 1 else points;
    let n : Int = Int.min(want, Int.min(mitigationCapPerScene - fate.sceneMitigation : Int, fate.fp));
    switch (r.tier) { case (#D) {}; case _ return #ok(r, fate, 0) };
    if (n <= 0) return #ok(r, fate, 0);
    let used = Int.abs(n);
    let f = switch (spendFate(fate, used)) { case (#err e) return #err e; case (#ok f) f };
    let nf = { f with sceneMitigation = fate.sceneMitigation + used };
    switch (resolveCheck(withRoll(r.input, Nat.min(r.die, r.roll + used)))) {
      case (#err e) #err e;
      case (#ok re) #ok(re, nf, used);
    };
  };

  // ---- damage lines (canon ruling 3) ----
  /// counts[L-1] = number of damage lines of level L suffered. Over DCs rise; Under DCs fall. The MODE never changes.
  public func adjustDC(baseDc : Nat, mode : Mode, counts : [Nat]) : { dc : Nat; shift : Nat } {
    var shift = 0;
    for (i in dcDamageThreshold.keys()) { if (i < counts.size()) { shift += counts[i] / dcDamageThreshold[i] } };
    let dc : Int = switch (mode) { case (#over) { baseDc + shift }; case (#under) { baseDc - shift } };
    { dc = Int.abs(Int.max(1, Int.min(64, dc))); shift };
  };

  /// With advantage/disadvantage keep the line that is better/worse FOR THE ACTOR: higher in Roll-Over, lower in Roll-Under.
  public func keepLine(dice : [Nat], mode : Mode, advantage : ?{ #adv; #dis }) : Nat {
    switch (advantage) {
      case null { dice[0] };
      case (?a) {
        if (dice.size() == 1) return dice[0];
        let hi = Array.foldLeft<Nat, Nat>(dice, 0, Nat.max);
        let lo = Array.foldLeft<Nat, Nat>(dice, 1000, Nat.min);
        let keepHigh = (mode == #over) == (a == #adv);
        if keepHigh hi else lo;
      };
    };
  };
};
