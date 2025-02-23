import Result "mo:base/Result";
import HashMap "mo:base/HashMap";
import Text "mo:base/Text";
import Principal "mo:base/Principal";
import Time "mo:base/Time";

actor IdentityBridge {

  // IdentityData defines the full Sentient profile.
  public type IdentityData = {
    principal: Principal;
    characterName: Text;
    personalityProfile: Text; // e.g., "Investigating Catalyst" (one of the 12 valid profiles)
    coreTraits: { conscious: Text; unconscious: Text };
    heritage: { name: Text; description: Text; baseAttributes: { [Text]: Nat }; surplus: Nat };
    journey: { description: Text; ageBand: Text };
    createdAt: Time.Time;
  };

  // Stable mapping from principal to IdentityData.
  private stable var identities = HashMap.HashMap<Principal, IdentityData>(10, Principal.equal, Principal.hash);

  // Register a new identity.
  public shared(msg) func registerIdentity(identity: IdentityData) : async Result.Result<Text, Text> {
    let caller = msg.caller;
    if (identities.get(caller) != null) {
      return #err("Identity already registered for this principal.");
    };
    identities.put(caller, identity);
    return #ok("Identity registered successfully.");
  };

  // Retrieve an identity by principal.
  public query func getIdentity(principal: Principal) : async ?IdentityData {
    identities.get(principal)
  };

  // Update an existing identity.
  public shared(msg) func updateIdentity(identity: IdentityData) : async Result.Result<Text, Text> {
    let caller = msg.caller;
    switch (identities.get(caller)) {
      case (null) { return #err("No identity registered for this principal."); };
      case (?existing) {
        if (caller == identity.principal) {
          identities.put(caller, identity);
          return #ok("Identity updated successfully.");
        } else {
          return #err("Unauthorized update attempt.");
        }
      }
    }
  };
};

