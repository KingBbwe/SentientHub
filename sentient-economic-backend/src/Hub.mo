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
import Bank "Bank";
import Int "mo:base/Int";
import Time "mo:base/Time";
import Nat "mo:base/Nat";
import Vitals "Vitals";
import Tongues "Tongues";
import Actions "Actions";
import Effects "Effects";

actor Hub {
  type State = Sentient.State;

  /// Persisted snapshot; the live map is rebuilt from it on every start (a HashMap is not a stable type).
  var saved : [(Principal, State)] = [];
  var savedAccounts : [(Principal, Bank.Account)] = [];
  transient let sentients = HashMap.fromIter<Principal, State>(saved.values(), 16, Principal.equal, Principal.hash);
  transient let accounts = HashMap.fromIter<Principal, Bank.Account>(savedAccounts.values(), 16, Principal.equal, Principal.hash);
  system func preupgrade() { saved := Iter.toArray(sentients.entries()); savedAccounts := Iter.toArray(accounts.entries()) };

  // ---- CrystalBank state (all rates are PLACEHOLDERS, see Bank.mo) ----
  var config : Bank.Config = Bank.defaultConfig;
  var orders : [Bank.Order] = [];
  var nextOrderId : Nat = 1;
  /// The FUDDY ledger this bank READS from. Mainnet by default; point it at a local replica ledger for playtests. Never used to send.
  var ledgerId : Text = "oeogn-qaaaa-aaaam-acoyq-cai";
  /// Last transfer fee read from the ledger; null = UNVERIFIED (withdrawals are refused until a fee has been read).
  var ledgerFee : ?Nat = null;

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

  /// Creates the caller's Sentient: starting Fate Points, the Will attribute (1-5; sets Resilience) and the Tongue its Tribe speaks, if any.
  /// One per principal.
  public shared ({ caller }) func register(fatePoints : Nat, will : Nat, tongue : ?Text) : async Result.Result<Sentient.Standing, Text> {
    switch (caller_(caller)) {
      case (#err e) #err e;
      case (#ok p) {
        if (sentients.get(p) != null) return #err("This principal already has a Sentient");
        if (will < 1 or will > 5) return #err("Will must be 1 to 5");
        switch (tongue) { case null {}; case (?t) { if (Tongues.find(t) == null) return #err("Unknown Tongue: " # t) } };
        let s = Sentient.newStateFor(fatePoints, will, tongue);
        sentients.put(p, s);
        #ok(Sentient.standing(s));
      };
    };
  };

  public shared query ({ caller }) func mySentient() : async ?State { sentients.get(caller) };
  public shared query ({ caller }) func myStanding() : async ?Sentient.Standing {
    switch (sentients.get(caller)) { case null null; case (?s) ?Sentient.standing(s) };
  };

  public type CheckOutcome = { result : Rules.CheckResult; rewards : [Types.ResourceReward]; standing : Sentient.Standing; disquietPenalty : Nat };

  /// Fetches 32 bytes of on-chain entropy for one check (the only async step). Refuses unregistered and anonymous callers first.
  func entropyFor(caller : Principal) : async Result.Result<Blob, Text> {
    switch (caller_(caller)) { case (#err e) return #err e; case (#ok _) {} };
    if (sentients.get(caller) == null) return #err("Register a Sentient first");
    #ok(await ic.raw_rand());
  };

  /// One check, synchronously, from entropy already fetched: rolls cast, die and Pull and resolves against the caller's Personal DC.
  /// Disquiet is a penalty to the modifier. The state is read here, AFTER the await, so there are no stale writes. Not written here.
  /// The Finite is advanced past the check's own rolls so the caller can draw amount dice from the same entropy.
  func resolveWith(f : Random.Finite, caller : Principal, die : Nat, mod : Int, dc : Nat, stepDown : Bool, resistPull : Bool) : Result.Result<(Rules.CheckResult, Dice.Rolls, Nat), Text> {
    let penalty = switch (sentients.get(caller)) { case null return #err("Register a Sentient first"); case (?s) Vitals.disquietPenalty(s.vitals) };
    let eff = switch (Rules.effectiveDie(die, stepDown)) { case (#err e) return #err e; case (#ok (d, _)) d };
    let rolls = switch (Dice.rolls(f, eff)) { case null return #err("Entropy exhausted; try again"); case (?r) r };
    let input : Rules.Input = { cast = rolls.cast; roll = rolls.roll; die; mod = mod - penalty; dc; modeDc = null; stepDown; pullRoll = rolls.pull; resistPull };
    switch (Rules.resolveCheck(input)) { case (#err e) #err e; case (#ok r) #ok(r, rolls, penalty) };
  };

  /// Rolls the cast, die and Pull on-chain, resolves the check against the caller's Personal DC and settles the rewards.
  public shared ({ caller }) func submitCheck(die : Nat, mod : Int, dc : Nat, stepDown : Bool, resistPull : Bool) : async Result.Result<CheckOutcome, Text> {
    let blob = switch (await entropyFor(caller)) { case (#err e) return #err e; case (#ok b) b };
    let (result, rolls, penalty) = switch (resolveWith(Random.Finite(blob), caller, die, mod, dc, stepDown, resistPull)) { case (#err e) return #err e; case (#ok x) x };
    switch (sentients.get(caller)) {
      case null #err("Sentient not found");
      case (?s) {
        let (next, rewards) = Sentient.settle(s, result, Data.questTemplates[rolls.cast - 1].rewards);
        sentients.put(caller, next);
        #ok({ result; rewards; standing = Sentient.standing(next); disquietPenalty = penalty });
      };
    };
  };

  public type ActionOutcome = { check : CheckOutcome; action : Text; applied : [Effects.Applied]; outgoing : [Effects.Outgoing]; resilienceBroken : Bool };

  /// A named action from the Action Economy: the check settles rewards as usual, then the action's resource effects for the tier that came up
  /// are applied to the caller. Effects aimed at a foe or allies are returned for the table. `path` selects Ganga-only or Doshi-only effects.
  public shared ({ caller }) func performAction(actionId : Nat, die : Nat, mod : Int, dc : Nat, stepDown : Bool, resistPull : Bool, path : Effects.Path) : async Result.Result<ActionOutcome, Text> {
    let action = switch (Actions.find(actionId)) { case null return #err("No such action"); case (?a) a };
    let blob = switch (await entropyFor(caller)) { case (#err e) return #err e; case (#ok b) b };
    let f = Random.Finite(blob);
    let (result, rolls, penalty) = switch (resolveWith(f, caller, die, mod, dc, stepDown, resistPull)) { case (#err e) return #err e; case (#ok x) x };
    switch (sentients.get(caller)) {
      case null #err("Sentient not found");
      case (?s) {
        switch (Effects.perform(s, action.effects, result.tier, path, f)) {
          case (#err e) #err e;                                  // e.g. not enough Fate Points: the whole action, rewards included, is refused
          case (#ok o) {
            let (next, rewards) = Sentient.settle(o.state, result, Data.questTemplates[rolls.cast - 1].rewards);
            sentients.put(caller, next);
            #ok({ check = { result; rewards; standing = Sentient.standing(next); disquietPenalty = penalty }; action = action.name; applied = o.applied; outgoing = o.outgoing; resilienceBroken = o.resilienceBroken });
          };
        };
      };
    };
  };

  /// Speaks the caller's Tongue: a check, the Tongue's TP cost, and burnout on a Disaster.
  public shared ({ caller }) func speakTongue(die : Nat, mod : Int, dc : Nat, stepDown : Bool, resistPull : Bool) : async Result.Result<CheckOutcome, Text> {
    switch (sentients.get(caller)) {
      case null return #err("Register a Sentient first");
      case (?s) { switch (Vitals.speak(s.vitals)) { case (#err e) return #err e; case (#ok _) {} } };         // fail fast, before the dice
    };
    let blob = switch (await entropyFor(caller)) { case (#err e) return #err e; case (#ok b) b };
    let (result, rolls, penalty) = switch (resolveWith(Random.Finite(blob), caller, die, mod, dc, stepDown, resistPull)) { case (#err e) return #err e; case (#ok x) x };
    switch (sentients.get(caller)) {
      case null #err("Sentient not found");
      case (?s) {
        switch (Vitals.speak(s.vitals)) {
          case (#err e) #err e;                                  // TP changed while the dice were in flight
          case (#ok (v, _)) {
            let (next, rewards) = Sentient.settle({ s with vitals = Vitals.afterSpeaking(v, result.tier) }, result, Data.questTemplates[rolls.cast - 1].rewards);
            sentients.put(caller, next);
            #ok({ result; rewards; standing = Sentient.standing(next); disquietPenalty = penalty });
          };
        };
      };
    };
  };

  public type Vitality = { vitals : Vitals.Vitals; disquietPenalty : Nat };
  public shared query ({ caller }) func myVitals() : async ?Vitality {
    switch (sentients.get(caller)) { case null null; case (?s) ?{ vitals = s.vitals; disquietPenalty = Vitals.disquietPenalty(s.vitals) } };
  };

  /// Once-per-rest master ability of the caller's Tongue.
  public shared ({ caller }) func useMasterAbility() : async Result.Result<Tongues.Master, Text> {
    switch (sentients.get(caller)) {
      case null #err("Register a Sentient first");
      case (?s) { switch (Vitals.useMaster(s.vitals)) { case (#err e) #err e; case (#ok (v, m)) { sentients.put(caller, { s with vitals = v }); #ok m } } };
    };
  };

  /// A long rest: Resilience, Disquiet, Tongue Power, burnout and the master ability reset.
  public shared ({ caller }) func longRest() : async Result.Result<Vitals.Vitals, Text> {
    switch (sentients.get(caller)) {
      case null #err("Register a Sentient first");
      case (?s) { let v = Vitals.longRest(s.vitals); sentients.put(caller, { s with vitals = v }); #ok v };
    };
  };

  /// Controllers only: applies an effect inflicted on a player (a foe's action's Outgoing, or a GM ruling).
  public shared ({ caller }) func gmApply(target : Principal, resource : Actions.Resource, dir : Actions.Dir, amount : Nat) : async Result.Result<Sentient.Standing, Text> {
    if (not (await isController(caller))) return #err("Only the canister controllers may apply effects to a Sentient");
    update_(target, func(s) { Effects.inflict(s, resource, dir, amount) });
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

  // ---- CrystalBank: claims and withdrawal orders. No signing, minting, burning or ledger transfers exist in this canister. ----
  func bankAccount(p : Principal) : Bank.Account { switch (accounts.get(p)) { case null Bank.newAccount(); case (?a) a } };

  public shared query ({ caller }) func myAccount() : async Bank.Account { bankAccount(caller) };
  public shared query ({ caller }) func myOrders() : async [Bank.Order] { Array.filter<Bank.Order>(orders, func(o) { o.owner == caller }) };
  public query func bankConfig() : async { config : Bank.Config; ledgerId : Text; ledgerFee : ?Nat } { { config; ledgerId; ledgerFee } };

  /// Turns crystals and in-game FUDDY from the caller's Sentient into a FUDDY claim at the configured (placeholder) rates.
  public shared ({ caller }) func convertToClaim(spend : Bank.Spend) : async Result.Result<Bank.Account, Text> {
    switch (caller_(caller)) { case (#err e) return #err e; case (#ok _) {} };
    switch (sentients.get(caller)) {
      case null #err("Register a Sentient first");
      case (?s) {
        switch (Bank.convert(config, s, bankAccount(caller), spend)) {
          case (#err e) #err e;
          case (#ok (s2, a2, _)) { sentients.put(caller, s2); accounts.put(caller, a2); #ok a2 };
        };
      };
    };
  };

  /// Opens a withdrawal ORDER for the custodian to settle by hand. The ledger fee comes out of the gross.
  public shared ({ caller }) func requestWithdrawal(gross : Nat) : async Result.Result<Bank.Order, Text> {
    switch (caller_(caller)) { case (#err e) return #err e; case (#ok _) {} };
    let fee = switch (ledgerFee) { case null return #err("The ledger fee has not been read yet (UNVERIFIED); withdrawals are paused"); case (?f) f };
    switch (Bank.quoteWithdrawal(config, { transfer = fee }, gross)) {
      case (#err e) #err e;
      case (#ok q) {
        switch (Bank.requestWithdrawal(bankAccount(caller), q)) {
          case (#err e) #err e;
          case (#ok a2) {
            let o : Bank.Order = { id = nextOrderId; owner = caller; gross = q.gross; fee = q.fee; net = q.net; created = Time.now(); status = #Pending };
            nextOrderId += 1; orders := Array.append(orders, [o]); accounts.put(caller, a2); #ok o;
          };
        };
      };
    };
  };

  func requireController(p : Principal) : async Result.Result<(), Text> {
    if (await isController(p)) #ok() else #err("Only the canister controllers may do this");
  };

  public shared ({ caller }) func pendingOrders() : async Result.Result<[Bank.Order], Text> {
    switch (await requireController(caller)) { case (#err e) #err e; case (#ok _) #ok(Array.filter<Bank.Order>(orders, func(o) { o.status == #Pending })) };
  };

  /// The custodian records what happened to an order they settled (or declined) outside this canister.
  public shared ({ caller }) func recordSettlement(id : Nat, outcome : Bank.Status) : async Result.Result<Bank.Order, Text> {
    switch (await requireController(caller)) { case (#err e) return #err e; case (#ok _) {} };
    switch (Array.find<Bank.Order>(orders, func(o) { o.id == id })) {
      case null #err("No such order");
      case (?o) {
        switch (Bank.settleOrder(bankAccount(o.owner), o, outcome)) {
          case (#err e) #err e;
          case (#ok (a2, o2)) { accounts.put(o.owner, a2); orders := Array.map<Bank.Order, Bank.Order>(orders, func(x) { if (x.id == id) o2 else x }); #ok o2 };
        };
      };
    };
  };

  /// PLACEHOLDER economics: the commander prices these.
  public shared ({ caller }) func setBankConfig(c : Bank.Config) : async Result.Result<(), Text> {
    switch (await requireController(caller)) { case (#err e) #err e; case (#ok _) { config := c; #ok() } };
  };

  public shared ({ caller }) func setLedger(id : Text) : async Result.Result<(), Text> {
    switch (await requireController(caller)) { case (#err e) #err e; case (#ok _) { ledgerId := id; ledgerFee := null; #ok() } };
  };

  /// READ-ONLY ledger call: icrc1_fee. Controllers only (it spends cycles).
  public shared ({ caller }) func refreshLedgerFee() : async Result.Result<Nat, Text> {
    switch (await requireController(caller)) { case (#err e) return #err e; case (#ok _) {} };
    let ledger : actor { icrc1_fee : () -> async Nat } = actor (ledgerId);
    let f = await ledger.icrc1_fee();
    ledgerFee := ?f;
    #ok f;
  };
};
