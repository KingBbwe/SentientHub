/// Types shared by the SentientHub modules. Kept free of state so every module can import it.
module {
  public type CrystalType = { #Type1; #Type2; #Type3; #Type4 };
  public type ResourceType = { #Fate; #Legendary; #Volitional; #Ovine; #Skullduggery; #Crystal : CrystalType; #InGameFUDDY; #GracePoints };
  public type ResourceReward = { resourceType : ResourceType; amount : Nat; narrativeSignificance : Text };
  public type NarrativeFragment = { triumph : Text; conflictDisaster : Text };
  public type QuestTemplate = { id : Nat; name : Text; description : Text; prerequisites : [Nat]; completionCriteria : Text; rewards : [ResourceReward] };
  public type AgeBand = { range : Text; description : Text };
  public type CharacterJourney = { id : Nat; trajectory : Text; perspective : Text };
};
