/// SentientHub canister, rebuild stage 4: the read-only rules surface plus per-Sentient economy and progression state.
/// No FUDDY ledger calls and no signing, minting or burning anywhere here (the live FUDDY canister is Stage 5).
/// Randomness: ONE source, the management canister's raw_rand (see rollFor); everything else is deterministic and tested in Motoko.
import Character "Character";
import Rules "Rules";
import Data "Data";
import Types "Types";
import Sentient "Sentient";
import Dice "Dice";
import Result "mo:base/Result";
import Principal "mo:base/Principal";
import HashMap "mo:base/HashMap";
import Iter "mo:base/Iter";
import Random "mo:base/Random";
import Array "mo:base/Array";

actor Hub {
  type State = Sentient.State;

  /// Persisted snapshot; the live map is rebuilt from it on every start (a HashMap is not a stable type).
  var saved : [(Principal, State)] = [];
  transient let sentients = HashMap.fromIter<Principal, State>(saved.values(), 16, Principal.equal, Principal.hash);
  system func preupgrade() { saved := Iter.toArray(sentients.entries()) };

  let ic : actor { raw_rand : () -> async Blob } = actor "aaaaa-aa";

  // ---- rules surface (read-only) ----
  public query func validateCharacter(c : Character.Character) : async [Text] { Character.validate(c) };
  public query func resolveCheck(i : Rules.Input) : async Result.Result<Rules.CheckResult, Text> { Rules.resolveCheck(i) };
  public query func ageBands() : async [Types.AgeBand] { Data.ageBands };
  public query func narrativeFor(hexagram : Nat) : async ?Types.NarrativeFragment {
    if (hexagram >= 1 and hexagram <= 64) { ?Data.narrativeFor(hexagram) } else { null };
  };
  public query func questTemplate(hexagram : Nat) : async ?Types.QuestTemplate {
    if (hexagram >= 1 and hexagram <= 64) { ?Data.questTemplates[hexagram - 1] } else { null };
  };

  // ---- Sentient state ----
  func caller_(p : Principal) : Result.Result<Principal, Text> {
    if (Principal.isAnonymous(p)) #err("Anonymous callers cannot hold a Sentient") else #ok p;
  };

  /// Creates the caller's Sentient with its starting Fate Points (a Character's creation decides the number). One per principal.
  public shared ({ caller }) func register(fatePoints : Nat) : async Result.Result<Sentient.Standing, Text> {
    switch (caller_(caller)) {
      case (#err e) #err e;
      case (#ok p) {
        if (sentients.get(p) != null) return #err("This principal already has a Sentient");
        let s = Sentient.newState(fatePoints);
        sentients.put(p, s);
        #ok(Sentient.standing(s));
      };
    };
  };

  public shared query ({ caller }) func mySentient() : async ?State { sentients.get(caller) };
  public shared query ({ caller }) func myStanding() : async ?Sentient.Standing {
    switch (sentients.get(caller)) { case null null; case (?s) ?Sentient.standing(s) };
  };

  public type CheckOutcome = { result : Rules.CheckResult; rewards : [Types.ResourceReward]; standing : Sentient.Standing };

  /// Rolls the cast, die and Pull on-chain, resolves the check against the caller's Personal DC and settles the rewards.
  public shared ({ caller }) func submitCheck(die : Nat, mod : Int, dc : Nat, stepDown : Bool, resistPull : Bool) : async Result.Result<CheckOutcome, Text> {
    switch (caller_(caller)) { case (#err e) return #err e; case (#ok _) {} };
    if (sentients.get(caller) == null) return #err("Register a Sentient first");
    let eff = switch (Rules.effectiveDie(die, stepDown)) { case (#err e) return #err e; case (#ok (d, _)) d };
    let entropy = await ic.raw_rand();                         // the state is read AFTER this await: no stale writes
    let rolls = switch (Dice.rolls(Random.Finite(entropy), eff)) { case null return #err("Entropy exhausted; try again"); case (?r) r };
    let input : Rules.Input = { cast = rolls.cast; roll = rolls.roll; die; mod; dc; modeDc = null; stepDown; pullRoll = rolls.pull; resistPull };
    let result = switch (Rules.resolveCheck(input)) { case (#err e) return #err e; case (#ok r) r };
    switch (sentients.get(caller)) {
      case null #err("Sentient not found");
      case (?s) {
        let (next, rewards) = Sentient.settle(s, result, Data.questTemplates[rolls.cast - 1].rewards);
        sentients.put(caller, next);
        #ok({ result; rewards; standing = Sentient.standing(next) });
      };
    };
  };

  func update_(p : Principal, f : State -> Result.Result<State, Text>) : Result.Result<Sentient.Standing, Text> {
    switch (caller_(p)) {
      case (#err e) #err e;
      case (#ok _) {
        switch (sentients.get(p)) {
          case null #err("Register a Sentient first");
          case (?s) { switch (f(s)) { case (#err e) #err e; case (#ok n) { sentients.put(p, n); #ok(Sentient.standing(n)) } } };
        };
      };
    };
  };

  /// Spends Fate Points (2 spent = 1 Skulduggery).
  public shared ({ caller }) func spendFate(n : Nat) : async Result.Result<Sentient.Standing, Text> {
    update_(caller, func(s) { switch (Sentient.spendFate(s, n)) { case (#err e) #err e; case (#ok (n2, _)) #ok n2 } });
  };

  /// Downtime: spends Grace to cleanse Skulduggery 1:1.
  public shared ({ caller }) func cleanse(amount : Nat) : async Result.Result<Sentient.Standing, Text> {
    update_(caller, func(s) { #ok(Sentient.cleanse(s, amount).0) });
  };

  public shared ({ caller }) func claimSkillset(name : Text) : async Result.Result<Sentient.Standing, Text> {
    update_(caller, func(s) { Sentient.claimSkillset(s, name) });
  };

  /// GM-granted: a Legendary Feat. Restricted to the controllers until Stage 5 defines who may award Feats.
  public shared ({ caller }) func awardFeat(target : Principal) : async Result.Result<Sentient.Standing, Text> {
    if (not (await isController(caller))) return #err("Only the canister controllers may award Legendary Feats");
    update_(target, func(s) { #ok(Sentient.awardFeat(s)) });
  };

  func isController(p : Principal) : async Bool {
    let mgmt : actor { canister_status : { canister_id : Principal } -> async { settings : { controllers : [Principal] } } } = actor "aaaaa-aa";
    let st = await mgmt.canister_status({ canister_id = Principal.fromActor(Hub) });
    Array.find<Principal>(st.settings.controllers, func(c) { c == p }) != null;
  };
};
