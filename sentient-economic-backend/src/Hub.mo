/// SentientHub canister, rebuild stage 3: the new, compiling surface. Read-only for now (query calls) so it can be checked and
/// exercised before any state is added. The old main.mo is being retired module by module (see docs/COMPILE_REPAIR_STATUS.md).
import Character "Character";
import Rules "Rules";
import Data "Data";
import Types "Types";
import Result "mo:base/Result";

actor Hub {
  /// Problems with a Character; empty means it is a valid auld-ewe.character v1 (same checks as identify-eweself).
  public query func validateCharacter(c : Character.Character) : async [Text] { Character.validate(c) };

  /// One Hex & Die resolution with explicit rolls (the caller supplies cast, die roll and Ovine Pull roll).
  public query func resolveCheck(i : Rules.Input) : async Result.Result<Rules.CheckResult, Text> { Rules.resolveCheck(i) };

  public query func ageBands() : async [Types.AgeBand] { Data.ageBands };
  public query func narrativeFor(hexagram : Nat) : async ?Types.NarrativeFragment {
    if (hexagram >= 1 and hexagram <= 64) { ?Data.narrativeFor(hexagram) } else { null };
  };
  public query func questTemplate(hexagram : Nat) : async ?Types.QuestTemplate {
    if (hexagram >= 1 and hexagram <= 64) { ?Data.questTemplates[hexagram - 1] } else { null };
  };
};
