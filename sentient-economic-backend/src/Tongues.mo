/// The 20 Tongues (generated from identify-eweself/tongues.js; do not hand-edit: tools/mo-check/gen-tongues-actions.js).
module {
  public type Resonance = { #Virtuous; #Challenging; #Neutral };
  public type Master = { name : Text; text : Text; resetsOnDay : Bool };
  public type Tongue = { id : Nat; name : Text; tribe : Text; resonance : Resonance; tp : Nat; synergy : [Text]; master : Master };

  public let tongues : [Tongue] = [
    { id = 1; name = "Hope Tongue"; tribe = "Tribe of Lightbearers"; resonance = #Virtuous; tp = 2; synergy = ["Courage Tongue", "Joy Tongue", "Unity Tongue"]; master = { name = "Dawn's Promise"; text = "Advantage on all party rolls once per long rest."; resetsOnDay = false } },
    { id = 2; name = "Courage Tongue"; tribe = "Tribe of Flamekin"; resonance = #Virtuous; tp = 3; synergy = ["Hope Tongue", "Trust Tongue", "Power"]; master = { name = "Unyielding Heart"; text = "Negate fear effects for the party for 10 minutes."; resetsOnDay = false } },
    { id = 3; name = "Joy Tongue"; tribe = "Tribe of Merrimakers"; resonance = #Virtuous; tp = 2; synergy = ["Hope Tongue", "Unity Tongue", "Courage Tongue"]; master = { name = "Celebration's Embrace"; text = "Euphoric aura for 1 hour."; resetsOnDay = false } },
    { id = 4; name = "Wisdom Tongue"; tribe = "Tribe of Seekers"; resonance = #Virtuous; tp = 3; synergy = ["Insight", "Memory", "Spirit Tongue"]; master = { name = "Sage's Revelation"; text = "Instantly solve one complex puzzle."; resetsOnDay = false } },
    { id = 5; name = "Unity Tongue"; tribe = "Tribe of Bridgebuilders"; resonance = #Virtuous; tp = 3; synergy = ["Courage Tongue", "Hope Tongue", "Power"]; master = { name = "Unite the Front"; text = "Party immune to fear and panic for 1 hour."; resetsOnDay = false } },
    { id = 6; name = "Strength Tongue"; tribe = "Tribe of Titans"; resonance = #Virtuous; tp = 2; synergy = ["Courage Tongue", "Trust Tongue"]; master = { name = "Titan's Might"; text = "Grant allies +4 strength for 1 round."; resetsOnDay = false } },
    { id = 7; name = "Healing Tongue"; tribe = "Tribe of Caretakers"; resonance = #Virtuous; tp = 2; synergy = ["Hope Tongue", "Courage Tongue"]; master = { name = "Restore the Broken"; text = "Fully heal an ally and remove debuffs."; resetsOnDay = false } },
    { id = 8; name = "Harmony Tongue"; tribe = "Tribe of Songweavers"; resonance = #Virtuous; tp = 2; synergy = ["Joy Tongue", "Unity Tongue"]; master = { name = "Melody's Embrace"; text = "Allies act freely without consequences for 1 round."; resetsOnDay = false } },
    { id = 9; name = "Fury Tongue"; tribe = "Tribe of Stormbringers"; resonance = #Challenging; tp = 3; synergy = ["Anger", "Conflict Tongue"]; master = { name = "Rage's Call"; text = "Grant allies advantage on attacks for 1 round."; resetsOnDay = false } },
    { id = 10; name = "Fear Tongue"; tribe = "Tribe of Dread"; resonance = #Challenging; tp = 3; synergy = ["Conflict Tongue", "Anger"]; master = { name = "Terror's Embrace"; text = "Incapacitate enemies in a 50ft radius."; resetsOnDay = false } },
    { id = 11; name = "Deceit Tongue"; tribe = "Tribe of Veilwalkers"; resonance = #Challenging; tp = 2; synergy = ["Fear Tongue", "Conflict Tongue"]; master = { name = "Master of Misdirection"; text = "Implant a false memory permanently."; resetsOnDay = false } },
    { id = 12; name = "Conflict Tongue"; tribe = "Tribe of Ironclad"; resonance = #Challenging; tp = 3; synergy = ["Fear Tongue", "Anger"]; master = { name = "Strife's End"; text = "Force a ceasefire for 1 hour."; resetsOnDay = false } },
    { id = 13; name = "Trust Tongue"; tribe = "Tribe of Ally"; resonance = #Neutral; tp = 2; synergy = ["Hope Tongue", "Courage Tongue"]; master = { name = "Unbreakable Bond"; text = "Auto-succeed on an ally saving throw."; resetsOnDay = false } },
    { id = 14; name = "Nature Tongue"; tribe = "Tribe of Rootkin"; resonance = #Neutral; tp = 2; synergy = ["Wisdom Tongue", "Memory"]; master = { name = "Wild Call"; text = "Summon a powerful natural ally for 1 hour."; resetsOnDay = true } },
    { id = 15; name = "Spirit Tongue"; tribe = "Tribe of Reverents"; resonance = #Neutral; tp = 3; synergy = ["Insight", "Trust Tongue"]; master = { name = "Soul's Harmony"; text = "Grant the party advantage on saving throws."; resetsOnDay = false } },
    { id = 16; name = "Trade Tongue"; tribe = "Tribe of Coinbearers"; resonance = #Neutral; tp = 2; synergy = ["Wisdom Tongue", "Insight"]; master = { name = "Merchant's Wit"; text = "Secure favorable trades."; resetsOnDay = false } },
    { id = 17; name = "Lament Tongue"; tribe = "Tribe of Griefkeepers"; resonance = #Neutral; tp = 2; synergy = ["Memory"]; master = { name = "Keeper's Vigil"; text = "Strengthen allies with memories of lost loved ones."; resetsOnDay = true } },
    { id = 18; name = "Riddle Tongue"; tribe = "Tribe of Puzzlers"; resonance = #Neutral; tp = 2; synergy = ["Insight"]; master = { name = "Puzzle Mastery"; text = "Solve any riddle instantly."; resetsOnDay = false } },
    { id = 19; name = "Chaos Tongue"; tribe = "Tribe of Maelstroms"; resonance = #Challenging; tp = 3; synergy = ["Anger"]; master = { name = "Maelstrom's Fury"; text = "Enemies act randomly for 1 round."; resetsOnDay = true } },
    { id = 20; name = "Truth Tongue"; tribe = "Tribe of Oathkeepers"; resonance = #Virtuous; tp = 3; synergy = ["Insight", "Courage Tongue"]; master = { name = "Revelation's Edge"; text = "Expose any lie."; resetsOnDay = true } }
  ];

  public func find(name : Text) : ?Tongue {
    for (x in tongues.values()) { if (x.name == name) return ?x };
    null;
  };
};
