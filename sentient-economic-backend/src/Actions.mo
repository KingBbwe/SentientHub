/// The Action Economy as data (generated from hex-die/engine/actions.js; do not hand-edit: tools/mo-check/gen-tongues-actions.js).
/// Canon dice only. Grace is never spent: where the source spent Grace the cost is Fate Points.
module {
  public type Phase = { #head; #melee; #armed };
  public type Side = { #offense; #defense };
  public type Kind = { #instinctual; #volitional; #synergistic };
  public type When = { #triumph; #conflict; #disaster; #always };
  public type Target = { #self; #foe; #allies };
  public type Resource = { #resilience; #disquiet; #skulduggery; #grace; #fate; #tp };
  public type Dir = { #gain; #lose };
  public type Cond = { #ganga; #doshi };
  public type Amount = { #fixed : Nat; #dice : (Nat, Nat) };
  public type Effect = { when : When; target : Target; resource : Resource; dir : Dir; amount : Amount; condition : ?Cond };
  public type Action = { id : Nat; name : Text; phase : Phase; side : Side; kind : Kind; effects : [Effect]; note : Text };
  public type Named = { name : Text; effects : [Effect]; note : Text };

  public let actions : [Action] = [
    { id = 1; name = "Horn Lock"; phase = #head; side = #offense; kind = #instinctual; effects = [{ when = #triumph; target = #foe; resource = #resilience; dir = #lose; amount = #dice (1, 6); condition = null }, { when = #conflict; target = #foe; resource = #resilience; dir = #lose; amount = #fixed 1; condition = null }, { when = #conflict; target = #self; resource = #resilience; dir = #lose; amount = #fixed 1; condition = null }, { when = #disaster; target = #self; resource = #disquiet; dir = #gain; amount = #fixed 1; condition = null }]; note = "Opposed Hex & Die roll." },
    { id = 2; name = "Charge Rush"; phase = #head; side = #offense; kind = #instinctual; effects = [{ when = #triumph; target = #foe; resource = #disquiet; dir = #gain; amount = #fixed 1; condition = null }]; note = "Force the opponent back 1d6 metres." },
    { id = 3; name = "Ancestral Taunt"; phase = #head; side = #offense; kind = #instinctual; effects = []; note = "Impose Disquiet on the foe (amount not given). Triumph: +2 to your next roll." },
    { id = 4; name = "Ground Stomp"; phase = #head; side = #offense; kind = #instinctual; effects = []; note = "Triumph: the opponent rerolls with Disadvantage." },
    { id = 5; name = "Ewe's Resolve"; phase = #head; side = #offense; kind = #instinctual; effects = []; note = "Auto-win if Triumph and the DC are met. Legendary Feat." },
    { id = 6; name = "Headbutt Barrage"; phase = #head; side = #offense; kind = #instinctual; effects = [{ when = #triumph; target = #foe; resource = #resilience; dir = #lose; amount = #dice (1, 6); condition = null }]; note = "Three rapid strikes, best 2 of 3 rounds." },
    { id = 7; name = "Primal Roar"; phase = #head; side = #offense; kind = #instinctual; effects = [{ when = #conflict; target = #self; resource = #disquiet; dir = #gain; amount = #fixed 1; condition = null }]; note = "Force a reroll on the opponent's next action." },
    { id = 8; name = "Hexagram Surge"; phase = #head; side = #offense; kind = #instinctual; effects = []; note = "Add the hexagram value to Resilience loss." },
    { id = 9; name = "Lockbreaker"; phase = #head; side = #offense; kind = #instinctual; effects = [{ when = #disaster; target = #self; resource = #resilience; dir = #lose; amount = #fixed 2; condition = null }]; note = "Escape grapples with Advantage." },
    { id = 10; name = "Ovine Fury"; phase = #head; side = #offense; kind = #instinctual; effects = [{ when = #always; target = #self; resource = #skulduggery; dir = #gain; amount = #fixed 5; condition = null }]; note = "Enter Seeing Red early." },
    { id = 11; name = "Horn Guard"; phase = #head; side = #defense; kind = #instinctual; effects = []; note = "Reduce Resilience loss by the hexagram value." },
    { id = 12; name = "Yield Gracefully"; phase = #head; side = #defense; kind = #instinctual; effects = [{ when = #always; target = #self; resource = #grace; dir = #gain; amount = #fixed 2; condition = null }]; note = "Concede." },
    { id = 13; name = "Ancestral Ward"; phase = #head; side = #defense; kind = #instinctual; effects = []; note = "Allies gain +2 to resist Disquiet." },
    { id = 14; name = "Stalwart Stance"; phase = #head; side = #defense; kind = #instinctual; effects = [{ when = #triumph; target = #foe; resource = #resilience; dir = #lose; amount = #dice (1, 6); condition = null }]; note = "Ignore knockback. Triumph reflects the loss." },
    { id = 15; name = "Hexagram Shield"; phase = #head; side = #defense; kind = #instinctual; effects = []; note = "Use the hexagram value as damage reduction." },
    { id = 16; name = "Tactical Retreat"; phase = #head; side = #defense; kind = #instinctual; effects = [{ when = #conflict; target = #self; resource = #resilience; dir = #lose; amount = #fixed 1; condition = null }]; note = "Disengage without penalty." },
    { id = 17; name = "Resilient Lock"; phase = #head; side = #defense; kind = #instinctual; effects = [{ when = #disaster; target = #self; resource = #disquiet; dir = #gain; amount = #fixed 1; condition = null }]; note = "Reroll a failed Defense roll." },
    { id = 18; name = "Bleat of Unity"; phase = #head; side = #defense; kind = #instinctual; effects = [{ when = #always; target = #allies; resource = #skulduggery; dir = #lose; amount = #fixed 1; condition = null }]; note = "Rally allies." },
    { id = 19; name = "Earthroot"; phase = #head; side = #defense; kind = #instinctual; effects = [{ when = #triumph; target = #self; resource = #grace; dir = #gain; amount = #fixed 1; condition = null }]; note = "Stabilize position: immune to prone." },
    { id = 20; name = "Sacred Concession"; phase = #head; side = #defense; kind = #instinctual; effects = [{ when = #always; target = #self; resource = #grace; dir = #gain; amount = #fixed 3; condition = null }]; note = "End combat honorably." },
    { id = 21; name = "Hoof Strike"; phase = #melee; side = #offense; kind = #volitional; effects = [{ when = #triumph; target = #foe; resource = #resilience; dir = #lose; amount = #dice (1, 8); condition = null }]; note = "Triumph also knocks the foe prone." },
    { id = 22; name = "Grapple Takedown"; phase = #melee; side = #offense; kind = #volitional; effects = [{ when = #triumph; target = #foe; resource = #resilience; dir = #lose; amount = #dice (1, 6); condition = null }]; note = "Opposed roll to restrain." },
    { id = 23; name = "Precision Jab"; phase = #melee; side = #offense; kind = #volitional; effects = [{ when = #triumph; target = #self; resource = #grace; dir = #gain; amount = #fixed 1; condition = null }]; note = "Bypass armor." },
    { id = 24; name = "Disarm Feint"; phase = #melee; side = #offense; kind = #volitional; effects = [{ when = #always; target = #self; resource = #skulduggery; dir = #gain; amount = #fixed 1; condition = null }]; note = "Remove a weapon." },
    { id = 25; name = "Whirlwind Kick"; phase = #melee; side = #offense; kind = #volitional; effects = []; note = "Hit 2 foes. Conflict: Resilience loss reduced by 1d6." },
    { id = 26; name = "Hexagram Combo"; phase = #melee; side = #offense; kind = #volitional; effects = []; note = "Chain attacks using hexagram lines." },
    { id = 27; name = "Skull Bash"; phase = #melee; side = #offense; kind = #volitional; effects = []; note = "Add Disquiet equal to the Resilience loss dealt." },
    { id = 28; name = "Trample Charge"; phase = #melee; side = #offense; kind = #volitional; effects = [{ when = #triumph; target = #foe; resource = #resilience; dir = #lose; amount = #dice (2, 6); condition = null }]; note = "Move 5m." },
    { id = 29; name = "Cornering Blow"; phase = #melee; side = #offense; kind = #volitional; effects = [{ when = #triumph; target = #foe; resource = #disquiet; dir = #gain; amount = #fixed 1; condition = null }]; note = "Trap the foe against terrain." },
    { id = 30; name = "Leg Sweep"; phase = #melee; side = #offense; kind = #volitional; effects = []; note = "Prone foe; Advantage for allies." },
    { id = 31; name = "Dodge Roll"; phase = #melee; side = #defense; kind = #volitional; effects = []; note = "Avoid Resilience loss. Triumph: counterattack." },
    { id = 32; name = "Shield Block"; phase = #melee; side = #defense; kind = #volitional; effects = []; note = "Reduce Resilience loss by 1d8." },
    { id = 33; name = "Guardian Stance"; phase = #melee; side = #defense; kind = #volitional; effects = []; note = "Protect an ally within 2m. Triumph: redirect the damage to yourself." },
    { id = 34; name = "Hexagram Parry"; phase = #melee; side = #defense; kind = #volitional; effects = []; note = "Use the hexagram value as damage reduction." },
    { id = 35; name = "Tactical Reposition"; phase = #melee; side = #defense; kind = #volitional; effects = [{ when = #conflict; target = #self; resource = #resilience; dir = #lose; amount = #fixed 1; condition = null }]; note = "Shift 3m without penalty." },
    { id = 36; name = "Defensive Chant"; phase = #melee; side = #defense; kind = #volitional; effects = [{ when = #always; target = #self; resource = #skulduggery; dir = #lose; amount = #dice (1, 6); condition = null }]; note = "Remove Skulduggery." },
    { id = 37; name = "Brace Impact"; phase = #melee; side = #defense; kind = #volitional; effects = []; note = "Halve Resilience loss but lose the Minor Action." },
    { id = 38; name = "Distracting Flourish"; phase = #melee; side = #defense; kind = #volitional; effects = [{ when = #always; target = #self; resource = #grace; dir = #gain; amount = #fixed 1; condition = null }]; note = "Draw aggro." },
    { id = 39; name = "Resilience Surge"; phase = #melee; side = #defense; kind = #volitional; effects = [{ when = #always; target = #self; resource = #fate; dir = #lose; amount = #fixed 1; condition = null }, { when = #always; target = #self; resource = #resilience; dir = #gain; amount = #dice (1, 6); condition = null }]; note = "The document converts 1 Grace; by ruling it costs 1 Fate Point." },
    { id = 40; name = "Honorable Yield"; phase = #melee; side = #defense; kind = #volitional; effects = [{ when = #always; target = #self; resource = #skulduggery; dir = #lose; amount = #fixed 3; condition = null }]; note = "End combat honorably." },
    { id = 41; name = "Skyrend Strike"; phase = #armed; side = #offense; kind = #synergistic; effects = [{ when = #always; target = #foe; resource = #resilience; dir = #lose; amount = #dice (10, 12); condition = null }, { when = #always; target = #self; resource = #skulduggery; dir = #gain; amount = #fixed 10; condition = null }]; note = "Legendary Feat." },
    { id = 42; name = "Hexagram Shot"; phase = #armed; side = #offense; kind = #synergistic; effects = []; note = "Triumph bypasses armor." },
    { id = 43; name = "Magical Barrage"; phase = #armed; side = #offense; kind = #synergistic; effects = [{ when = #always; target = #self; resource = #skulduggery; dir = #gain; amount = #fixed 2; condition = ?#doshi }]; note = "Cast a spell and make a weapon attack." },
    { id = 44; name = "Thunderhoof Charge"; phase = #armed; side = #offense; kind = #synergistic; effects = [{ when = #triumph; target = #foe; resource = #resilience; dir = #lose; amount = #dice (3, 8); condition = null }]; note = "Trample a line of foes." },
    { id = 45; name = "Dual Wield"; phase = #armed; side = #offense; kind = #synergistic; effects = []; note = "Attack twice. Disaster: the weapon breaks." },
    { id = 46; name = "Soulfire Blade"; phase = #armed; side = #offense; kind = #synergistic; effects = []; note = "Add the hexagram value to Resilience loss." },
    { id = 47; name = "Aetherix Overload"; phase = #armed; side = #offense; kind = #synergistic; effects = [{ when = #disaster; target = #self; resource = #skulduggery; dir = #gain; amount = #dice (1, 6); condition = null }]; note = "Sacrifice the weapon for double damage." },
    { id = 48; name = "Rending Hexagram"; phase = #armed; side = #offense; kind = #synergistic; effects = []; note = "Apply a hexagram debuff." },
    { id = 49; name = "Precision Volley"; phase = #armed; side = #offense; kind = #synergistic; effects = []; note = "Ignore range penalties. Triumph: critical (double Resilience loss)." },
    { id = 50; name = "Corruption Surge"; phase = #armed; side = #offense; kind = #synergistic; effects = []; note = "Deal +1d12 Resilience loss per Skulduggery point held; risks Broken Honor." },
    { id = 51; name = "Ward of Grace"; phase = #armed; side = #defense; kind = #synergistic; effects = [{ when = #always; target = #self; resource = #grace; dir = #gain; amount = #fixed 2; condition = ?#ganga }]; note = "Absorb 1d12 Resilience loss." },
    { id = 52; name = "Hexagram Barrier"; phase = #armed; side = #defense; kind = #synergistic; effects = []; note = "Block attacks equal to the hexagram lines." },
    { id = 53; name = "Sacrificial Guard"; phase = #armed; side = #defense; kind = #synergistic; effects = []; note = "Take an ally's damage and convert it to Skulduggery." },
    { id = 54; name = "Purifying Light"; phase = #armed; side = #defense; kind = #synergistic; effects = [{ when = #always; target = #self; resource = #skulduggery; dir = #lose; amount = #dice (2, 6); condition = null }]; note = "Hexagram 40." },
    { id = 55; name = "Aegis Formation"; phase = #armed; side = #defense; kind = #synergistic; effects = []; note = "Allies gain damage reduction 5 against Resilience loss." },
    { id = 56; name = "Counterflux"; phase = #armed; side = #defense; kind = #synergistic; effects = [{ when = #always; target = #self; resource = #skulduggery; dir = #gain; amount = #dice (1, 6); condition = ?#doshi }]; note = "Reflect spell damage." },
    { id = 57; name = "Ancestral Recall"; phase = #armed; side = #defense; kind = #synergistic; effects = []; note = "Reroll a Disaster using the hexagram's changing lines." },
    { id = 58; name = "Sanctuary Veil"; phase = #armed; side = #defense; kind = #synergistic; effects = [{ when = #always; target = #self; resource = #fate; dir = #lose; amount = #fixed 3; condition = null }]; note = "Become immune to Resilience loss." },
    { id = 59; name = "Harmonic Resonance"; phase = #armed; side = #defense; kind = #synergistic; effects = []; note = "Share with allies. The document shares Grace; by ruling it costs Fate Points (amount not given)." },
    { id = 60; name = "Final Stand"; phase = #armed; side = #defense; kind = #synergistic; effects = [{ when = #always; target = #self; resource = #skulduggery; dir = #gain; amount = #fixed 10; condition = null }]; note = "Auto-succeed the Defense." }
  ];

  public let states : [Named] = [
    { name = "Seeing Red (offensive)"; effects = []; note = "+1d12 Resilience loss but lose 1 ally." },
    { name = "Seeing Red (defensive)"; effects = [{ when = #always; target = #self; resource = #skulduggery; dir = #gain; amount = #fixed 5; condition = null }]; note = "Ignore damage." }
  ];

  public let dishonor : [Named] = [
    { name = "Draw a weapon"; effects = [{ when = #always; target = #self; resource = #skulduggery; dir = #gain; amount = #fixed 1; condition = null }]; note = "Stated in the document example. Skipping phases also earns Skulduggery, but no amount is given." }
  ];

  public func find(id : Nat) : ?Action {
    if (id >= 1 and id <= actions.size()) { ?actions[id - 1] } else { null };
  };
};
