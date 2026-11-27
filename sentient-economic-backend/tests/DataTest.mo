import Data "../src/Data";
import Debug "mo:base/Debug";
import Array "mo:base/Array";
import Text "mo:base/Text";

// Stage 1 checks: shape and counts of the static data. Any failure traps.
assert Data.validProfiles.size() == 12;
assert Data.ageBands.size() == 2;
assert Data.ageBands[0].range == "18-36";
assert Data.ageBands[1].range == "36-50+";
assert Data.coreTraits.size() == 64;
assert Data.characterJourneys.size() == 64;
assert Data.questTemplates.size() == 64;
for (i in Array.keys(Data.coreTraits)) { assert Data.coreTraits[i].0 == i + 1 };
for (i in Array.keys(Data.questTemplates)) {
  let q = Data.questTemplates[i];
  assert q.id == i + 1;
  assert q.rewards.size() == 2;
  assert q.name.size() > 0 and q.completionCriteria.size() > 0;
  let f = Data.narrativeFor(q.id);
  assert f.triumph.size() > 0 and f.conflictDisaster.size() > 0;
};
for (i in Array.keys(Data.characterJourneys)) { assert Data.characterJourneys[i].0 == i + 1 };
assert Text.contains(Data.narrativeFor(60).triumph, #text "limits");
Debug.print("DataTest ok");
