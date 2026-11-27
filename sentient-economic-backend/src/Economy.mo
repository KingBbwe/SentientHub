/// Rewards and resource balances, pure. Ports generate{Triumph,Conflict,Disaster}Rewards, calculateRewardScale and applyRewards from main.mo,
/// keyed to the approved join table instead of the draft's own dice test (RULES_CANON 6B).
///
/// FLAGGED INTERPRETATIONS:
///  - Reward by join cell: pass:Triumph -> the Triumph set + the quest's prize in full; pass:Conflict -> the Conflict set + half the prize;
///    pass:Disaster and fail:Disaster -> the Disaster set (Skulduggery, a Type-4 crystal); fail:Triumph and fail:Conflict -> nothing.
///  - REWARD_CAPS: crystals and in-game FUDDY are BALANCE caps (as in the draft; they limit what can later be converted to FUDDY).
///    GRACE_POINTS_MAX = 3 is a per-grant cap: applied as a balance cap it would pin the Grace meter at 3 and make the 25-point
///    Grace threshold unreachable.
///  - The reward scale uses the Personal DC of the check (the draft used a quest DC that no longer exists) and the Venerable level.
import Nat "mo:base/Nat";
import Array "mo:base/Array";
import Types "Types";
import Rules "Rules";

module {
  type ResourceReward = Types.ResourceReward;

  public let CRYSTAL1_MAX : Nat = 100;
  public let CRYSTAL2_MAX : Nat = 80;
  public let CRYSTAL3_MAX : Nat = 50;
  public let CRYSTAL4_MAX : Nat = 20;
  public let INGAME_FUDDY_MAX : Nat = 20;
  public let GRACE_PER_GRANT_MAX : Nat = 3;

  /// What a Sentient holds that is not Fate Points, Skulduggery or Grace (those live in Rules.Fate and Progression.Moral).
  public type Balance = { legendary : Nat; volitional : Nat; ovine : Nat; type1 : Nat; type2 : Nat; type3 : Nat; type4 : Nat; inGameFuddy : Nat };

  public func newBalance() : Balance { { legendary = 0; volitional = 0; ovine = 0; type1 = 0; type2 = 0; type3 = 0; type4 = 0; inGameFuddy = 0 } };

  /// Reward scale in percent: DC/100 x (1 + level/10), clamped to 20..100 (the draft's 0.2..1.0). Integer arithmetic throughout.
  public func scalePct(dc : Nat, venerableLevel : Nat) : Nat {
    let raw = dc * (10 + venerableLevel) / 10;
    Nat.min(100, Nat.max(20, raw));
  };

  func scaled(base : Nat, pct : Nat) : Nat { base * pct / 100 };

  func triumph(pct : Nat) : [ResourceReward] {
    [
      { resourceType = #GracePoints; amount = 1; narrativeSignificance = "Divine favor earned through triumphant success" },
      { resourceType = #Crystal(#Type1); amount = scaled(10, pct); narrativeSignificance = "Crystallized essence of victory" },
      { resourceType = #Fate; amount = 2; narrativeSignificance = "Destiny points earned through heroic deed" },
    ];
  };
  func conflict(pct : Nat) : [ResourceReward] {
    [
      { resourceType = #Crystal(#Type2); amount = scaled(5, pct); narrativeSignificance = "Fragments of challenged victory" },
      { resourceType = #InGameFUDDY; amount = 1; narrativeSignificance = "Strategic insight gained through struggle" },
    ];
  };
  let disaster : [ResourceReward] = [
    { resourceType = #Skullduggery; amount = 1; narrativeSignificance = "Dark wisdom earned through failure" },
    { resourceType = #Crystal(#Type4); amount = 1; narrativeSignificance = "Shard of bitter experience" },
  ];

  /// The rewards for a resolved check. dc = the Personal DC used; prize = the quest template's own rewards.
  public func rewardsFor(pass : Bool, tier : Rules.Tier, dc : Nat, venerableLevel : Nat, prize : [ResourceReward]) : [ResourceReward] {
    let pct = scalePct(dc, venerableLevel);
    let base : [ResourceReward] = switch (pass, tier) {
      case (true, #T) Array.append(triumph(pct), prize);
      case (true, #C) Array.append(conflict(pct), Array.map<ResourceReward, ResourceReward>(prize, func(r) { { r with amount = r.amount / 2 } }));
      case (true, #D) disaster;
      case (false, #D) disaster;
      case (false, _) [];
    };
    Array.filter<ResourceReward>(base, func(r) { r.amount > 0 });
  };

  /// Applies the per-grant cap (Grace only). Everything else passes through.
  public func capGrant(r : ResourceReward) : ResourceReward {
    switch (r.resourceType) { case (#GracePoints) { { r with amount = Nat.min(r.amount, GRACE_PER_GRANT_MAX) } }; case _ r };
  };

  /// Adds one reward to the balance, honouring the balance caps. Fate, Skulduggery and Grace are not balance items: unchanged here.
  public func applyToBalance(b : Balance, r : ResourceReward) : Balance {
    switch (r.resourceType) {
      case (#Crystal(#Type1)) { { b with type1 = Nat.min(b.type1 + r.amount, CRYSTAL1_MAX) } };
      case (#Crystal(#Type2)) { { b with type2 = Nat.min(b.type2 + r.amount, CRYSTAL2_MAX) } };
      case (#Crystal(#Type3)) { { b with type3 = Nat.min(b.type3 + r.amount, CRYSTAL3_MAX) } };
      case (#Crystal(#Type4)) { { b with type4 = Nat.min(b.type4 + r.amount, CRYSTAL4_MAX) } };
      case (#InGameFUDDY) { { b with inGameFuddy = Nat.min(b.inGameFuddy + r.amount, INGAME_FUDDY_MAX) } };
      case (#Legendary) { { b with legendary = b.legendary + r.amount } };
      case (#Volitional) { { b with volitional = b.volitional + r.amount } };
      case (#Ovine) { { b with ovine = b.ovine + r.amount } };
      case (#Fate or #Skullduggery or #GracePoints) b;
    };
  };
};
