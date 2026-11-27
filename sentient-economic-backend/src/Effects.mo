/// Performs an action's resource effects. Pure given the entropy (Random.Finite), so every result can be replayed from the blob.
///
/// Effects on the actor ('self') change the actor's State; effects on a foe or on allies cannot (their state is not here), so they are
/// RETURNED as Outgoing for the table, or the controllers' gmApply, to apply. A Fate Point cost is paid first and atomically: if the
/// Sentient cannot pay, nothing changes. Fate Points spent follow the canon accrual (every 2 spent = 1 Skulduggery), through Sentient.spendFate.
import Result "mo:base/Result";
import Array "mo:base/Array";
import Random "mo:base/Random";
import Actions "Actions";
import Rules "Rules";
import Dice "Dice";
import Progression "Progression";
import Sentient "Sentient";
import Vitals "Vitals";

module {
  public type Path = { #none; #ganga; #doshi };
  public type Outgoing = { target : Actions.Target; resource : Actions.Resource; dir : Actions.Dir; amount : Nat };
  public type Applied = { resource : Actions.Resource; dir : Actions.Dir; amount : Nat };
  public type Outcome = { state : Sentient.State; applied : [Applied]; outgoing : [Outgoing]; resilienceBroken : Bool };

  func fires(w : Actions.When, tier : Rules.Tier) : Bool {
    switch (w, tier) { case (#always, _) true; case (#triumph, #T) true; case (#conflict, #C) true; case (#disaster, #D) true; case _ false };
  };

  func pathOk(c : ?Actions.Cond, p : Path) : Bool {
    switch (c, p) { case (null, _) true; case (?#ganga, #ganga) true; case (?#doshi, #doshi) true; case _ false };
  };

  /// The effects that fire for this tier and path.
  public func firing(effects : [Actions.Effect], tier : Rules.Tier, path : Path) : [Actions.Effect] {
    Array.filter<Actions.Effect>(effects, func(e) { fires(e.when, tier) and pathOk(e.condition, path) });
  };

  /// A fixed amount, or the sum of its dice drawn from the entropy. null if the entropy runs out.
  public func resolveAmount(f : Random.Finite, a : Actions.Amount) : ?Nat {
    switch (a) {
      case (#fixed n) ?n;
      case (#dice (n, faces)) {
        var total = 0;
        var i = 0;
        while (i < n) {
          switch (Dice.draw(f, faces)) { case null return null; case (?v) { total += v } };
          i += 1;
        };
        ?total;
      };
    };
  };

  public func minAmount(a : Actions.Amount) : Nat { switch (a) { case (#fixed n) n; case (#dice (n, _)) n } };
  public func maxAmount(a : Actions.Amount) : Nat { switch (a) { case (#fixed n) n; case (#dice (n, faces)) n * faces } };

  /// Applies one resolved effect to the actor's own state.
  func applySelf(s : Sentient.State, r : Actions.Resource, d : Actions.Dir, n : Nat) : Result.Result<(Sentient.State, Bool), Text> {
    switch (r, d) {
      case (#resilience, #lose) { let (v, broken) = Vitals.loseResilience(s.vitals, n); #ok({ s with vitals = v }, broken) };
      case (#resilience, #gain) #ok({ s with vitals = Vitals.gainResilience(s.vitals, n) }, false);
      case (#disquiet, #gain) #ok({ s with vitals = Vitals.gainDisquiet(s.vitals, n) }, false);
      case (#disquiet, #lose) #ok({ s with vitals = Vitals.loseDisquiet(s.vitals, n) }, false);
      case (#skulduggery, #gain) #ok({ s with moral = Progression.addSkulduggery(s.moral, n) }, false);
      case (#skulduggery, #lose) #ok({ s with moral = Progression.removeSkulduggery(s.moral, n) }, false);
      case (#grace, #gain) #ok({ s with moral = Progression.addGrace(s.moral, n) }, false);
      case (#grace, #lose) #ok({ s with moral = Progression.reduceGrace(s.moral, n) }, false);
      case (#fate, #gain) #ok({ s with fate = { s.fate with fp = s.fate.fp + n } }, false);
      case (#fate, #lose) { switch (Sentient.spendFate(s, n)) { case (#err e) #err e; case (#ok (s2, _)) #ok(s2, false) } };
      case (#tp, #gain) #ok({ s with vitals = Vitals.gainTP(s.vitals, n) }, false);
      case (#tp, #lose) #ok({ s with vitals = Vitals.loseTP(s.vitals, n) }, false);
    };
  };

  /// Performs an action: draws every amount first, pays Fate Point costs first, then applies the rest. All or nothing.
  public func perform(s : Sentient.State, effects : [Actions.Effect], tier : Rules.Tier, path : Path, f : Random.Finite) : Result.Result<Outcome, Text> {
    let live = firing(effects, tier, path);
    var amounts : [Nat] = [];
    for (e in live.values()) {
      switch (resolveAmount(f, e.amount)) { case null return #err("Entropy exhausted; try again"); case (?n) { amounts := Array.append(amounts, [n]) } };
    };
    var st = s;
    var applied : [Applied] = [];
    var outgoing : [Outgoing] = [];
    var broken = false;
    // pass 1: Fate Point costs, so an unaffordable action changes nothing
    var i = 0;
    for (e in live.values()) {
      if (e.target == #self and e.resource == #fate and e.dir == #lose) {
        switch (applySelf(st, e.resource, e.dir, amounts[i])) {
          case (#err m) return #err m;
          case (#ok (s2, _)) { st := s2; applied := Array.append(applied, [{ resource = e.resource; dir = e.dir; amount = amounts[i] }]) };
        };
      };
      i += 1;
    };
    // pass 2: everything else
    i := 0;
    for (e in live.values()) {
      let n = amounts[i];
      if (e.target == #self) {
        if (not (e.resource == #fate and e.dir == #lose)) {
          switch (applySelf(st, e.resource, e.dir, n)) {
            case (#err m) return #err m;
            case (#ok (s2, b)) { st := s2; if b { broken := true }; applied := Array.append(applied, [{ resource = e.resource; dir = e.dir; amount = n }]) };
          };
        };
      } else {
        outgoing := Array.append(outgoing, [{ target = e.target; resource = e.resource; dir = e.dir; amount = n }]);
      };
      i += 1;
    };
    #ok({ state = st; applied; outgoing; resilienceBroken = broken });
  };

  /// Applies an effect inflicted on this Sentient by someone else (a foe's action, or the GM). No Fate cost logic: the victim pays nothing.
  public func inflict(s : Sentient.State, r : Actions.Resource, d : Actions.Dir, n : Nat) : Result.Result<Sentient.State, Text> {
    switch (r, d) {
      case (#fate, #lose) { let fp = if (n >= s.fate.fp) 0 else s.fate.fp - n; #ok({ s with fate = { s.fate with fp } }) };
      case _ { switch (applySelf(s, r, d, n)) { case (#err e) #err e; case (#ok (s2, _)) #ok s2 } };
    };
  };
};
