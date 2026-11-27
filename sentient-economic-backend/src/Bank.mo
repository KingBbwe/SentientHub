/// CrystalBank rules, pure. Converts a Sentient's crystals and in-game FUDDY into a FUDDY *claim*, and turns claims into withdrawal
/// ORDERS. It never signs, mints or burns, and makes no ledger calls: settlement of an order is performed by the human custodian outside
/// this code, who then records the outcome (txid or failure). That is the standing FUDDY rule, applied literally.
///
/// ALL ECONOMICS ARE PLACEHOLDERS (`Config.placeholder = true`): no tokenomics were supplied. The default rates below are the draft's
/// 1/5/10/20 and the unit they are measured in (FUDDY smallest unit vs whole tokens) is UNVERIFIED until icrc1_decimals is read from the live ledger.
/// Ledger fees are token behaviour, not bugs: a withdrawal pays the transfer fee out of the gross, so net < gross, and amounts at or below the fee are refused.
import Result "mo:base/Result";
import Nat "mo:base/Nat";
import Sentient "Sentient";
import Economy "Economy";

module {
  public type Rates = { type1 : Nat; type2 : Nat; type3 : Nat; type4 : Nat; inGameFuddy : Nat };
  public type Config = { rates : Rates; minWithdraw : Nat; placeholder : Bool };
  public type Fee = { transfer : Nat };

  /// PLACEHOLDER - commander to price.
  public let defaultConfig : Config = { rates = { type1 = 1; type2 = 5; type3 = 10; type4 = 20; inGameFuddy = 1 }; minWithdraw = 1; placeholder = true };

  /// Per-principal bank account. Invariant: converted = claim + pending + settledGross.
  public type Account = { claim : Nat; pending : Nat; settledGross : Nat; converted : Nat };
  public func newAccount() : Account { { claim = 0; pending = 0; settledGross = 0; converted = 0 } };

  public type Spend = { type1 : Nat; type2 : Nat; type3 : Nat; type4 : Nat; inGameFuddy : Nat };

  public type Status = { #Pending; #Settled : Text; #Failed : Text };
  /// A withdrawal order: what the custodian must send. net is what the recipient gets, fee is what the ledger takes.
  public type Order = { id : Nat; owner : Principal; gross : Nat; fee : Nat; net : Nat; created : Int; status : Status };

  public func valueOf(c : Config, s : Spend) : Nat {
    s.type1 * c.rates.type1 + s.type2 * c.rates.type2 + s.type3 * c.rates.type3 + s.type4 * c.rates.type4 + s.inGameFuddy * c.rates.inGameFuddy;
  };

  public func isEmpty(s : Spend) : Bool { s.type1 + s.type2 + s.type3 + s.type4 + s.inGameFuddy == 0 };

  /// Moves crystals / in-game FUDDY out of the Sentient's balance into the bank account as a claim. Returns (state, account, claim added).
  public func convert(c : Config, st : Sentient.State, a : Account, s : Spend) : Result.Result<(Sentient.State, Account, Nat), Text> {
    if (isEmpty(s)) return #err("Nothing to convert");
    let b = st.balance;
    if (s.type1 > b.type1) return #err("Not enough Type 1 crystals");
    if (s.type2 > b.type2) return #err("Not enough Type 2 crystals");
    if (s.type3 > b.type3) return #err("Not enough Type 3 crystals");
    if (s.type4 > b.type4) return #err("Not enough Type 4 crystals");
    if (s.inGameFuddy > b.inGameFuddy) return #err("Not enough in-game FUDDY");
    let v = valueOf(c, s);
    if (v == 0) return #err("Those rates value this conversion at zero");
    let nb : Economy.Balance = { b with type1 = b.type1 - s.type1; type2 = b.type2 - s.type2; type3 = b.type3 - s.type3; type4 = b.type4 - s.type4; inGameFuddy = b.inGameFuddy - s.inGameFuddy };
    #ok({ st with balance = nb }, { a with claim = a.claim + v; converted = a.converted + v }, v);
  };

  public type Quote = { gross : Nat; fee : Nat; net : Nat };

  public func quoteWithdrawal(c : Config, f : Fee, gross : Nat) : Result.Result<Quote, Text> {
    if (gross < c.minWithdraw) return #err("Below the minimum withdrawal of " # Nat.toText(c.minWithdraw));
    if (gross <= f.transfer) return #err("Amount does not cover the ledger transfer fee of " # Nat.toText(f.transfer));
    #ok({ gross; fee = f.transfer; net = gross - f.transfer });
  };

  /// Reserves the gross from the claim and opens an order (the fee is the ledger's, so it is part of the gross).
  public func requestWithdrawal(a : Account, q : Quote) : Result.Result<Account, Text> {
    if (q.gross > a.claim) return #err("Insufficient claim: " # Nat.toText(a.claim) # " available");
    #ok({ a with claim = a.claim - q.gross; pending = a.pending + q.gross });
  };

  /// Records the custodian's outcome. Settled: the gross has left the bank. Failed: it returns to the claim. Only a Pending order can be settled.
  public func settleOrder(a : Account, o : Order, outcome : Status) : Result.Result<(Account, Order), Text> {
    switch (o.status) { case (#Pending) {}; case _ return #err("Order " # Nat.toText(o.id) # " is already closed") };
    if (o.gross > a.pending) return #err("Ledger inconsistency: order exceeds pending");
    switch (outcome) {
      case (#Pending) #err("Outcome must be Settled or Failed");
      case (#Settled _) #ok({ a with pending = a.pending - o.gross; settledGross = a.settledGross + o.gross }, { o with status = outcome });
      case (#Failed _) #ok({ a with pending = a.pending - o.gross; claim = a.claim + o.gross }, { o with status = outcome });
    };
  };

  public func balanced(a : Account) : Bool { a.converted == a.claim + a.pending + a.settledGross };
};
