/// The `auld-ewe.character` v1 contract as a Candid-friendly record, plus its validator.
/// Port of identify-eweself/character.js `validateCharacter`; the error strings are kept identical so the two can be compared
/// (see tests/CharacterParity.mo, generated from the JS side). Import path: the front end turns the JSON file into this record
/// (missing `acquired` becomes []), the canister validates it, then stores it.
import Array "mo:base/Array";
import Nat "mo:base/Nat";
import Int "mo:base/Int";
import Text "mo:base/Text";
import Skills "Skills";

module {
  public type Mode = { #over; #under };
  public type Gender = { #ewe; #ram };
  public type AllocationMode = { #seeded; #free };

  public type DC = { value : Nat; band : Text; mode : Mode; source : Text };
  public type Attributes = { Inspiration : Nat; Intellect : Nat; Prowess : Nat; SelfAwareness : Nat; Instinct : Nat; Drive : Nat; Energy : Nat; Emotion : Nat; Will : Nat };
  public type Allocation = { rule : Text; mode : AllocationMode; budget : Nat; spent : Nat; remaining : Nat; complete : Bool; rerollPenalty : Nat; floors : Attributes };
  public type TrajectoryEnd = { role : Text; hexagram : Nat; name : Text };
  public type CoreTrait = { trait : Text; hexagram : Nat };

  public type SoulRoll = { dice : (Nat, Nat); rerolls : [Nat] };
  public type TraitRolls = { conscious : ?(Nat, Nat); unconscious : ?(Nat, Nat) };
  public type Creation = { soulRoll : ?SoulRoll; traitRolls : ?TraitRolls; skillRoll : ?{ picks : [Text] }; rollCount : Nat; penalty : Nat };

  public type Character = {
    schema : Text;
    version : Nat;
    id : Text;
    createdAt : Text;
    name : Text;
    gender : Gender;
    nameHexagram : Nat;
    renamesRemaining : Nat;
    soul : { pattern : Text; profile : (Nat, Nat); profileId : Text; profileName : Text };
    coreTraits : { conscious : CoreTrait; unconscious : CoreTrait };
    trajectory : { id : Nat; ageBand : Text; a : TrajectoryEnd; b : TrajectoryEnd };
    dc : { intellectual : DC; physical : DC; emotional : DC; spiritual : DC };
    lineage : { name : Text; type_ : Text; role : Text; traits : [Text] };
    tribe : { name : Text; tongue : Text; resonance : Text };
    attributes : Attributes;
    allocation : Allocation;
    acquired : [(Text, Int)];
    skills : [(Text, Int)];
    dieTier : Nat;
    skulduggery : Nat;
    grace : Nat;
    creation : ?Creation;
  };

  public let SCHEMA = "auld-ewe.character";
  public let VERSION : Nat = 1;
  let AGE_BANDS = ["18-36", "36-50+"];
  let VALID_PROFILES : [(Nat, Nat)] = [(1, 3), (1, 4), (2, 4), (2, 5), (3, 5), (3, 6), (4, 6), (4, 1), (5, 1), (5, 2), (6, 2), (6, 3)];
  let TOTAL : Nat = 32;
  let MIN : Nat = 1;
  let MAX : Nat = 5;

  /// Roll-Over / Roll-Under bands by DC (RULES_CANON ruling 4): 1-16 over, 17-32 under, 33-48 over, 49-64 under.
  public func modeForDC(dc : Nat) : Mode {
    if (dc <= 16 or (dc >= 33 and dc <= 48)) #over else #under;
  };
  func modeText(m : Mode) : Text { switch (m) { case (#over) "over"; case (#under) "under" } };

  func isValidProfile(a : Nat, b : Nat) : Bool {
    for (p in VALID_PROFILES.values()) { if (p.0 == a and p.1 == b) return true };
    false;
  };

  let ATTR_NAMES = ["Inspiration", "Intellect", "Prowess", "SelfAwareness", "Instinct", "Drive", "Energy", "Emotion", "Will"];
  func attrList(a : Attributes) : [Nat] { [a.Inspiration, a.Intellect, a.Prowess, a.SelfAwareness, a.Instinct, a.Drive, a.Energy, a.Emotion, a.Will] };

  func allocationProblems(c : Character) : [Text] {
    let e = Buffer();
    let vals = attrList(c.attributes);
    let flo = attrList(c.allocation.floors);
    var total = 0;
    var floorSum = 0;
    for (i in vals.keys()) {
      let a = ATTR_NAMES[i];
      let v = vals[i];
      let f = flo[i];
      if (v < MIN or v > MAX) { e.add("attribute " # a # " must be an integer 1-5") } else { total += v };
      if (f < MIN or f > MAX) { e.add("floor " # a # " must be an integer 1-5") } else {
        floorSum += f;
        if (v < f) { e.add("attribute " # a # " is below its floor") };
      };
    };
    if (c.allocation.mode == #free) {
      for (f in flo.values()) { if (f != MIN) { e.add("free-build floors must all be 1") } };
    };
    // free-build is reported once, as in the JS (a single check over all floors)
    let es = dedupeFirst(e.toArray(), "free-build floors must all be 1");
    if (es.size() > 0) return es;
    let al = c.allocation;
    let out = Buffer();
    if (al.spent != total) { out.add("allocation.spent " # Nat.toText(al.spent) # " does not equal the attribute total " # Nat.toText(total)) };
    if (al.budget < floorSum) { out.add("allocation.budget is below the sum of the floors") };
    if (total > al.budget) { out.add("attributes total " # Nat.toText(total) # " exceeds the budget " # Nat.toText(al.budget)) };
    if (al.remaining + total != al.budget) { out.add("allocation.remaining must equal budget minus spent") };
    if (al.complete != (al.remaining == 0)) { out.add("allocation.complete must be true exactly when nothing remains") };
    if (al.budget > TOTAL) { out.add("allocation.budget cannot exceed " # Nat.toText(TOTAL)) };
    out.toArray();
  };

  // A tiny append-only text buffer so this file needs no mutable-array helpers.
  class Buffer() {
    var items : [Text] = [];
    public func add(t : Text) { items := Array.append(items, [t]) };
    public func toArray() : [Text] { items };
  };

  func dedupeFirst(xs : [Text], t : Text) : [Text] {
    var seen = false;
    Array.filter<Text>(xs, func(x) { if (x == t) { if (seen) { false } else { seen := true; true } } else { true } });
  };

  func has(list : [(Text, Int)], name : Text) : Bool {
    for (p in list.values()) { if (p.0 == name) return true };
    false;
  };

  /// All problems with a Character; empty means valid. Same checks and the same wording as validateCharacter in character.js.
  public func validate(c : Character) : [Text] {
    let e = Buffer();
    if (c.schema != SCHEMA) { e.add("schema must be \"" # SCHEMA # "\"") };
    if (c.version != VERSION) { e.add("unsupported version " # Nat.toText(c.version) # " (this build reads " # Nat.toText(VERSION) # ")") };
    if (c.id == "") { e.add("id missing") };
    if (c.name == "") { e.add("name missing") };
    if (not isValidProfile(c.soul.profile.0, c.soul.profile.1)) { e.add("soul.profile is not one of the twelve valid pairs") };

    let doms : [(Text, DC)] = [("intellectual", c.dc.intellectual), ("physical", c.dc.physical), ("emotional", c.dc.emotional), ("spiritual", c.dc.spiritual)];
    for ((d, x) in doms.values()) {
      if (x.value < 1 or x.value > 64) { e.add("dc." # d # " missing or outside 1-64") } else if (x.mode != modeForDC(x.value)) {
        e.add("dc." # d # " mode \"" # modeText(x.mode) # "\" does not match DC " # Nat.toText(x.value) # " (expected " # modeText(modeForDC(x.value)) # ")");
      };
    };
    if (c.dc.intellectual.value != c.coreTraits.conscious.hexagram) { e.add("dc.intellectual must equal the conscious core-trait hexagram") };
    if (c.dc.physical.value != c.coreTraits.unconscious.hexagram) { e.add("dc.physical must equal the unconscious core-trait hexagram") };
    if (c.dc.emotional.value != c.trajectory.a.hexagram) { e.add("dc.emotional must equal trajectory.a") };
    if (c.dc.spiritual.value != c.trajectory.b.hexagram) { e.add("dc.spiritual must equal trajectory.b") };

    if (not (c.dieTier == 6 or c.dieTier == 8 or c.dieTier == 12 or c.dieTier == 20)) { e.add("dieTier must be 6, 8, 12 or 20") };
    var ageOk = false;
    for (b in AGE_BANDS.values()) { if (b == c.trajectory.ageBand) { ageOk := true } };
    if (not ageOk) { e.add("trajectory.ageBand must be one of 18-36, 36-50+") };

    for (m in allocationProblems(c).values()) { e.add(m) };
    if (c.allocation.rule != "32-point") { e.add("allocation.rule must be \"32-point\"") };

    for ((k, v) in c.skills.values()) {
      if (not Skills.isSkill(k)) { e.add("unknown skill: " # k) } else if (v < Skills.DEFAULT) { e.add("skill " # k # " must be an integer of at least " # Int.toText(Skills.DEFAULT)) };
    };
    for ((k, v) in c.acquired.values()) {
      if (not Skills.isAcquired(k)) { e.add("unknown acquired skillset: " # k) } else if (v < 0) { e.add("acquired skillset " # k # " must be an integer of at least 0") };
    };

    switch (c.creation) {
      case null {};
      case (?cr) {
        switch (cr.skillRoll) {
          case null {};
          case (?sr) {
            var distinct = true;
            for (i in sr.picks.keys()) { for (j in sr.picks.keys()) { if (i < j and sr.picks[i] == sr.picks[j]) { distinct := false } } };
            if (not distinct) { e.add("creation.skillRoll.picks must be distinct skill names") } else {
              for (n in sr.picks.values()) { if (not has(c.skills, n)) { e.add("creation.skillRoll: " # n # " is not on the sheet") } };
            };
          };
        };
        switch (cr.soulRoll) {
          case null {};
          case (?sr) {
            let d = sr.dice;
            let p = c.soul.profile;
            let rr = sr.rerolls;
            if (d.0 != p.0) { e.add("creation.soulRoll: the first die must be kept (" # Nat.toText(d.0) # " vs profile " # Nat.toText(p.0) # ")") };
            let endsOk = if (rr.size() == 0) { d.1 == p.1 } else { rr[rr.size() - 1] == p.1 };
            if (not endsOk) { e.add("creation.soulRoll does not end on the stated profile") };
            if ((rr.size() == 0) != isValidProfile(d.0, d.1)) { e.add("creation.soulRoll: rerolls must happen exactly when the first pair is invalid") };
            if (rr.size() > 1) {
              for (i in Array.keys(rr)) { if (i + 1 < rr.size() and isValidProfile(d.0, rr[i])) { e.add("creation.soulRoll: rolling should have stopped at " # Nat.toText(d.0) # "/" # Nat.toText(rr[i])) } };
            };
          };
        };
        switch (cr.traitRolls) {
          case null {};
          case (?tr) {
            switch (tr.conscious) {
              case null {};
              case (?x) { if ((x.0 + 0) < 1 or (x.0 - 1 : Nat) * 8 + x.1 != c.coreTraits.conscious.hexagram) { e.add("creation.traitRolls.conscious does not give hexagram " # Nat.toText(c.coreTraits.conscious.hexagram)) } };
            };
            switch (tr.unconscious) {
              case null {};
              case (?x) { if ((x.0 + 0) < 1 or (x.0 - 1 : Nat) * 8 + x.1 != c.coreTraits.unconscious.hexagram) { e.add("creation.traitRolls.unconscious does not give hexagram " # Nat.toText(c.coreTraits.unconscious.hexagram)) } };
            };
          };
        };
      };
    };
    e.toArray();
  };
};
