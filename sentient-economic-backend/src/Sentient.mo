/// One Sentient's economy and progression state, and the pure transitions on it. No randomness, no I/O: the Hub supplies the rolled
/// CheckResult. Every transition returns a new state (or an error) so each can be tested in isolation and replayed from a log.
///
/// What a check settles: rewards by join cell (Economy.rewardsFor), Skulduggery and Grace into the moral meters (Progression),
/// Fate Points into the Fate wallet, everything else into the capped balance. Spending Fate Points adds Skulduggery 1 per 2 spent.
import Result "mo:base/Result";
import Array "mo:base/Array";
import Nat "mo:base/Nat";
import Types "Types";
import Rules "Rules";
import Progression "Progression";
import Economy "Economy";
import Skills "Skills";
import Vitals "Vitals";

module {
  public type State = {
    moral : Progression.Moral;
    balance : Economy.Balance;
    fate : Rules.Fate;
    feats : Nat;                  // Legendary Feats awarded
    held : [Text];                // Acquired Skillsets held
    checks : Nat;
    vitals : Vitals.Vitals;       // Resilience, Disquiet, Tongue Power
  };

  public func newState(fatePoints : Nat) : State { newStateFor(fatePoints, Vitals.DEFAULT_WILL, null) };

  /// A new Sentient: Fate Points, the Will attribute (sets Resilience), and the Tongue its Tribe speaks, if any.
  public func newStateFor(fatePoints : Nat, will : Nat, tongue : ?Text) : State {
    { moral = Progression.newMoral(); balance = Economy.newBalance(); fate = Rules.newFate(fatePoints); feats = 0; held = []; checks = 0; vitals = Vitals.newVitals(will, tongue) };
  };

  func applyReward(s : State, r : Types.ResourceReward) : State {
    let g = Economy.capGrant(r);
    switch (g.resourceType) {
      case (#GracePoints) { { s with moral = Progression.addGrace(s.moral, g.amount) } };
      case (#Skullduggery) { { s with moral = Progression.addSkulduggery(s.moral, g.amount) } };
      case (#Fate) { { s with fate = { s.fate with fp = s.fate.fp + g.amount } } };
      case _ { { s with balance = Economy.applyToBalance(s.balance, g) } };
    };
  };

  /// Settles a resolved check: grants the rewards for its join cell and returns them with the new state.
  public func settle(s : State, r : Rules.CheckResult, prize : [Types.ResourceReward]) : (State, [Types.ResourceReward]) {
    let rewards = Economy.rewardsFor(r.pass, r.tier, r.input.dc, Progression.venerableLevel(s.moral), prize);
    var next : State = { s with checks = s.checks + 1 };
    for (x in rewards.values()) { next := applyReward(next, x) };
    (next, rewards);
  };

  /// Spends Fate Points; every 2nd point spent (cumulative) adds 1 Skulduggery. Returns the new state and the Skulduggery incurred.
  public func spendFate(s : State, n : Nat) : Result.Result<(State, Nat), Text> {
    switch (Rules.spendFate(s.fate, n)) {
      case (#err e) #err e;
      case (#ok f) {
        let owed = Progression.skulduggeryForFate(s.fate.spent, f.spent);
        #ok({ s with fate = f; moral = Progression.addSkulduggery(s.moral, owed) }, owed);
      };
    };
  };

  /// Downtime: spends Grace to cleanse uncrystallised Skulduggery 1:1. Returns the new state and the amount cleansed.
  public func cleanse(s : State, amount : Nat) : (State, Nat) {
    let (m, c) = Progression.cleanse(s.moral, amount);
    ({ s with moral = m }, c);
  };

  public func awardFeat(s : State) : State { { s with feats = s.feats + 1 } };

  /// Takes an Acquired Skillset using an earned slot (5 Feats -> Medal, 5 Medals -> a slot).
  public func claimSkillset(s : State, name : Text) : Result.Result<State, Text> {
    if (not Skills.isAcquired(name)) return #err("Not an Acquired Skillset: " # name);
    for (h in s.held.values()) { if (h == name) return #err("Already held: " # name) };
    if (Progression.skillSlots(s.feats) <= s.held.size()) return #err("No Acquired Skillset slot available (5 Feats make a Medal, 5 Medals make a slot)");
    #ok({ s with held = Array.append(s.held, [name]) });
  };

  func natSub(a : Nat, b : Nat) : Nat { if (a > b) a - b else 0 };

  public func venerable(s : State) : Bool { Progression.isVenerable(s.held.size()) };

  public type Standing = { villainy : Text; venerableLevel : Text; vices : Nat; virtues : Nat; graces : Nat; medals : Nat; slotsFree : Nat; venerableStatus : Bool };

  public func standing(s : State) : Standing {
    {
      villainy = Progression.villainyNames[Progression.villainyLevel(s.moral)];
      venerableLevel = Progression.venerableNames[Progression.venerableLevel(s.moral)];
      vices = Progression.vices(s.moral); virtues = Progression.virtues(s.moral); graces = Progression.graces(s.moral);
      medals = Progression.medals(s.feats);
      slotsFree = natSub(Progression.skillSlots(s.feats), s.held.size());
      venerableStatus = venerable(s);
    };
  };
};
