import Result "mo:base/Result";
import HashMap "mo:base/HashMap";
import Text "mo:base/Text";
import Nat "mo:base/Nat";

actor CrystalBank {
  type TransactionResult = Result.Result<Text, Text>;

  // Dummy wallet data for demonstration.
  var walletData = {
    crb: 1500000 : Nat,
    fuddy: 850000 : Nat,
    realFuddy: 1000 : Nat,
    inGameFuddy: 500 : Nat,
    stakes: 12.5,
    nfts: 47 : Nat,
    crystalBalance: 200 : Nat
  };

  public shared func getBalance(playerId: Text) : async Nat {
    walletData.realFuddy
  };

  public shared func depositCrystals(playerId: Text, crystalType: Text, amount: Nat, annotation: Text) : async TransactionResult {
    if (amount <= 0) {
      return #err("Amount must be positive");
    };
    walletData.crystalBalance += amount;
    return #ok("Crystals deposited successfully with annotation: " # annotation);
  };

  public shared func transferCrystals(fromPlayerId: Text, toPlayerId: Text, crystalType: Text, amount: Nat, annotation: Text) : async TransactionResult {
    if (amount <= 0) {
      return #err("Amount must be positive");
    };
    return #ok("Crystals transferred successfully with annotation: " # annotation);
  };
};
