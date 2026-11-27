/// Moral and achievement ladders, as pure functions on small records. Replaces the draft's three conflicting progression designs
/// (a checkpoint table, a points table and 20 sub-levels) with ONE ladder built from the constants the route marked canon-compliant:
///
///   Villainy:  Skulduggery --20--> Twisted Taint --5--> Vice --4--> Villainy level (None .. Abyssal, 7 steps)
///   Virtue:    Grace       --25--> a Grace       --4--> Virtue --5--> Venerable level (None .. Divine, 7 steps)
///   Feats:     Legendary Feat --5--> Medal --5--> Acquired Skillset slot; 5 Acquired Skillsets = Venerable status
///
/// Rulings it follows: 2 Fate Points spent = 1 Skulduggery; Grace is a moral meter that cleanses Skulduggery in downtime.
/// FLAGGED INTERPRETATIONS: Taints are permanent once crystallised (only the uncrystallised Skulduggery meter can be cleansed),
/// cleansing costs 1 Grace per 1 Skulduggery, and the draft's 1-20 sub-levels and attribute growth are not built (not canon).
import Nat "mo:base/Nat";

module {
  public let SKULDUGGERY_MAX : Nat = 20;      // Skulduggery that crystallises into one Twisted Taint
  public let TAINTS_FOR_VICE : Nat = 5;
  public let MAX_VICES : Nat = 4;             // Vices per Villainy level
  public let GRACE_THRESHOLD : Nat = 25;      // Grace earned per Grace
  public let GRACES_FOR_VIRTUE : Nat = 4;
  public let MAX_VIRTUES : Nat = 5;           // Virtues per Venerable level
  public let FEATS_FOR_MEDAL : Nat = 5;
  public let MEDALS_FOR_SKILL : Nat = 5;
  public let SKILLS_FOR_VENERABLE : Nat = 5;
  public let MAX_LEVEL : Nat = 7;

  public let villainyNames : [Text] = ["None", "Skulduggerous", "Duplicitous", "Treacherous", "Malevolent", "Tyrannical", "Diabolical", "Abyssal"];
  public let venerableNames : [Text] = ["None", "Respected", "Revered", "Exalted", "Sanctified", "Hallowed", "Transcendent", "Divine"];

  /// skulduggery and grace are the live meters (grace can be spent); the totals are monotonic and drive the ladders.
  public type Moral = { skulduggery : Nat; taints : Nat; totalSkulduggery : Nat; grace : Nat; totalGrace : Nat };

  public func newMoral() : Moral { { skulduggery = 0; taints = 0; totalSkulduggery = 0; grace = 0; totalGrace = 0 } };

  /// Adds Skulduggery; every 20 crystallises into a permanent Twisted Taint.
  public func addSkulduggery(m : Moral, n : Nat) : Moral {
    let meter = m.skulduggery + n;
    { m with skulduggery = meter % SKULDUGGERY_MAX; taints = m.taints + meter / SKULDUGGERY_MAX; totalSkulduggery = m.totalSkulduggery + n };
  };

  public func addGrace(m : Moral, n : Nat) : Moral { { m with grace = m.grace + n; totalGrace = m.totalGrace + n } };

  /// In-play Skulduggery removal (Defensive Chant, Purifying Light, Honorable Yield...): only the uncrystallised meter, never Taints.
  public func removeSkulduggery(m : Moral, n : Nat) : Moral { { m with skulduggery = if (n >= m.skulduggery) 0 else m.skulduggery - n } };

  /// Reduces the Grace meter (an effect inflicted on someone). The ladder counts totalGrace, so it never goes down.
  public func reduceGrace(m : Moral, n : Nat) : Moral { { m with grace = if (n >= m.grace) 0 else m.grace - n } };

  /// Spends Grace to cleanse Skulduggery 1:1, limited by the Grace held and the uncrystallised Skulduggery. Returns (moral, amount cleansed).
  public func cleanse(m : Moral, amount : Nat) : (Moral, Nat) {
    let c = Nat.min(amount, Nat.min(m.skulduggery, m.grace));
    ({ m with skulduggery = m.skulduggery - c; grace = m.grace - c }, c);
  };

  /// Skulduggery owed when Fate Points spent goes from oldSpent to newSpent (2 FP = 1 Skulduggery, cumulative).
  public func skulduggeryForFate(oldSpent : Nat, newSpent : Nat) : Nat { newSpent / 2 - oldSpent / 2 };

  public func vices(m : Moral) : Nat { m.taints / TAINTS_FOR_VICE };
  public func villainyLevel(m : Moral) : Nat { Nat.min(vices(m) / MAX_VICES, MAX_LEVEL) };
  public func graces(m : Moral) : Nat { m.totalGrace / GRACE_THRESHOLD };
  public func virtues(m : Moral) : Nat { graces(m) / GRACES_FOR_VIRTUE };
  public func venerableLevel(m : Moral) : Nat { Nat.min(virtues(m) / MAX_VIRTUES, MAX_LEVEL) };

  public func medals(feats : Nat) : Nat { feats / FEATS_FOR_MEDAL };
  /// Acquired Skillset slots earned so far (held skillsets use them up).
  public func skillSlots(feats : Nat) : Nat { medals(feats) / MEDALS_FOR_SKILL };
  /// Venerable status: enough Acquired Skillsets held.
  public func isVenerable(heldSkillsets : Nat) : Bool { heldSkillsets >= SKILLS_FOR_VENERABLE };
};
