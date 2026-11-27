/// Resilience, Disquiet and Tongue Power: the three tracked values the Action Economy and Tongues documents add, as pure functions.
///
/// ALL NUMBERS HERE ARE PLACEHOLDERS - commander to price (the documents give no maxima, penalties or recovery rates):
///  - Resilience maximum = RESILIENCE_BASE + RESILIENCE_PER_WILL x Will. It replaces HP ("Resilience loss"); Will is the Volitional attribute,
///    so it sets how much a Sentient can bear. Reaching 0 is reported, not punished: the document names no consequence.
///  - Disquiet: capped at DISQUIET_MAX; each point is -1 to every roll (the document says only "penalizing rolls").
///  - Tongue Power: TP_MAX pool, spent per Tongue use (cost from Tongues.mo). A Disaster on a Tongue use triggers burnout, and a master
///    ability is once per rest. Everything resets on a long rest (the document's "successful Wisdom save" cure is not modelled: no Wisdom attribute).
import Result "mo:base/Result";
import Nat "mo:base/Nat";
import Rules "Rules";
import Tongues "Tongues";

module {
  public let RESILIENCE_BASE : Nat = 20;
  public let RESILIENCE_PER_WILL : Nat = 4;
  public let DISQUIET_MAX : Nat = 10;
  public let TP_MAX : Nat = 6;
  public let DEFAULT_WILL : Nat = 3;

  public type Vitals = {
    resilience : Nat; resilienceMax : Nat;
    disquiet : Nat;
    tp : Nat; tpMax : Nat;
    tongue : ?Text; masterUsed : Bool; burnout : Bool;
  };

  public func resilienceMaxFor(will : Nat) : Nat { RESILIENCE_BASE + RESILIENCE_PER_WILL * will };

  public func newVitals(will : Nat, tongue : ?Text) : Vitals {
    let m = resilienceMaxFor(will);
    { resilience = m; resilienceMax = m; disquiet = 0; tp = TP_MAX; tpMax = TP_MAX; tongue; masterUsed = false; burnout = false };
  };

  /// Returns the new vitals and whether Resilience reached 0 with this loss.
  public func loseResilience(v : Vitals, n : Nat) : (Vitals, Bool) {
    let r = if (n >= v.resilience) 0 else v.resilience - n;
    ({ v with resilience = r }, r == 0 and v.resilience > 0);
  };
  public func gainResilience(v : Vitals, n : Nat) : Vitals { { v with resilience = Nat.min(v.resilience + n, v.resilienceMax) } };

  public func gainDisquiet(v : Vitals, n : Nat) : Vitals { { v with disquiet = Nat.min(v.disquiet + n, DISQUIET_MAX) } };
  public func loseDisquiet(v : Vitals, n : Nat) : Vitals { { v with disquiet = if (n >= v.disquiet) 0 else v.disquiet - n } };
  /// The roll penalty Disquiet imposes (subtract from the modifier).
  public func disquietPenalty(v : Vitals) : Nat { v.disquiet };

  public func gainTP(v : Vitals, n : Nat) : Vitals { { v with tp = Nat.min(v.tp + n, v.tpMax) } };
  public func loseTP(v : Vitals, n : Nat) : Vitals { { v with tp = if (n >= v.tp) 0 else v.tp - n } };

  /// Spends the Tongue's TP cost. Errors if the Sentient has no Tongue or too little TP. Returns the cost paid.
  public func speak(v : Vitals) : Result.Result<(Vitals, Nat), Text> {
    let name = switch (v.tongue) { case null return #err("This Sentient has no Tongue"); case (?n) n };
    let t = switch (Tongues.find(name)) { case null return #err("Unknown Tongue: " # name); case (?t) t };
    if (v.tp < t.tp) return #err("Not enough Tongue Power: " # Nat.toText(v.tp) # " of " # Nat.toText(t.tp) # " needed");
    #ok({ v with tp = v.tp - t.tp }, t.tp);
  };

  /// A Disaster while speaking a Tongue triggers its burnout (a temporary debuff, cleared by a long rest).
  public func afterSpeaking(v : Vitals, tier : Rules.Tier) : Vitals { switch (tier) { case (#D) { { v with burnout = true } }; case _ v } };

  /// Once-per-rest master ability. Free of TP (the document gives no cost).
  public func useMaster(v : Vitals) : Result.Result<(Vitals, Tongues.Master), Text> {
    let name = switch (v.tongue) { case null return #err("This Sentient has no Tongue"); case (?n) n };
    let t = switch (Tongues.find(name)) { case null return #err("Unknown Tongue: " # name); case (?t) t };
    if (v.masterUsed) return #err(t.master.name # " has already been used since the last rest");
    #ok({ v with masterUsed = true }, t.master);
  };

  /// A long rest: Resilience, Disquiet, TP, burnout and the master ability all reset.
  public func longRest(v : Vitals) : Vitals {
    { v with resilience = v.resilienceMax; disquiet = 0; tp = v.tpMax; masterUsed = false; burnout = false };
  };
};
