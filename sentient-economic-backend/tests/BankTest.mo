import B "../src/Bank";
import S "../src/Sentient";
import Debug "mo:base/Debug";
import Principal "mo:base/Principal";
import Iter "mo:base/Iter";

let c = B.defaultConfig;
assert c.placeholder;
let none : B.Spend = { type1 = 0; type2 = 0; type3 = 0; type4 = 0; inGameFuddy = 0 };
func rich() : S.State { let s = S.newState(0); { s with balance = { s.balance with type1 = 100; type2 = 80; type3 = 50; type4 = 20; inGameFuddy = 20 } } };

assert B.valueOf(c, { none with type1 = 3; type2 = 2; type3 = 1; type4 = 1; inGameFuddy = 4 }) == 3 + 10 + 10 + 20 + 4;
// converting moves value, never invents it
switch (B.convert(c, rich(), B.newAccount(), { none with type2 = 10; type4 = 2 })) {
  case (#ok(st, a, v)) { assert v == 50 + 40 and a.claim == 90 and a.converted == 90 and st.balance.type2 == 70 and st.balance.type4 == 18 and B.balanced(a) };
  case (#err _) { assert false };
};
// refusals leave nothing changed
switch (B.convert(c, rich(), B.newAccount(), none)) { case (#err _) {}; case (#ok _) { assert false } };
switch (B.convert(c, rich(), B.newAccount(), { none with type1 = 101 })) { case (#err _) {}; case (#ok _) { assert false } };
switch (B.convert(c, rich(), B.newAccount(), { none with inGameFuddy = 21 })) { case (#err _) {}; case (#ok _) { assert false } };
let zeroRates = { c with rates = { type1 = 0; type2 = 0; type3 = 0; type4 = 0; inGameFuddy = 0 } };
switch (B.convert(zeroRates, rich(), B.newAccount(), { none with type1 = 1 })) { case (#err _) {}; case (#ok _) { assert false } };
// fees: net < gross, fee-or-less refused, below minimum refused
let fee : B.Fee = { transfer = 10 };
switch (B.quoteWithdrawal(c, fee, 100)) { case (#ok q) { assert q.gross == 100 and q.fee == 10 and q.net == 90 }; case (#err _) { assert false } };
switch (B.quoteWithdrawal(c, fee, 10)) { case (#err _) {}; case (#ok _) { assert false } };
switch (B.quoteWithdrawal(c, fee, 9)) { case (#err _) {}; case (#ok _) { assert false } };
switch (B.quoteWithdrawal({ c with minWithdraw = 50 }, { transfer = 0 }, 49)) { case (#err _) {}; case (#ok _) { assert false } };
switch (B.quoteWithdrawal(c, { transfer = 0 }, 1)) { case (#ok q) { assert q.net == 1 }; case (#err _) { assert false } };
// the full cycle conserves value: settle and fail
let owner = Principal.fromText("2vxsx-fae");
var a : B.Account = { claim = 500; pending = 0; settledGross = 0; converted = 500 };
let q1 = switch (B.quoteWithdrawal(c, fee, 200)) { case (#ok q) q; case (#err _) { assert false; loop {} } };
a := switch (B.requestWithdrawal(a, q1)) { case (#ok x) x; case (#err _) { assert false; loop {} } };
assert a.claim == 300 and a.pending == 200 and B.balanced(a);
let o1 : B.Order = { id = 1; owner; gross = q1.gross; fee = q1.fee; net = q1.net; created = 0; status = #Pending };
switch (B.settleOrder(a, o1, #Settled "tx-1")) {
  case (#ok(a2, o2)) { assert a2.pending == 0 and a2.settledGross == 200 and a2.claim == 300 and B.balanced(a2) and o2.status == #Settled "tx-1";
    switch (B.settleOrder(a2, o2, #Failed "late")) { case (#err _) {}; case (#ok _) { assert false } } };      // no double close
  case (#err _) { assert false };
};
switch (B.settleOrder(a, o1, #Failed "custodian declined")) { case (#ok(a3, _)) { assert a3.claim == 500 and a3.pending == 0 and a3.settledGross == 0 and B.balanced(a3) }; case (#err _) { assert false } };
switch (B.settleOrder(a, o1, #Pending)) { case (#err _) {}; case (#ok _) { assert false } };
// cannot withdraw more than the claim, nor reserve twice
switch (B.requestWithdrawal(a, { gross = 301; fee = 10; net = 291 })) { case (#err _) {}; case (#ok _) { assert false } };
// conservation across many random-ish steps
var acc = B.newAccount(); var st = rich(); var i = 0;
for (k in Iter.range(0, 59)) {
  let sp : B.Spend = { none with type1 = k % 3; type2 = k % 2; inGameFuddy = k % 5 };
  switch (B.convert(c, st, acc, sp)) { case (#ok(s2, a2, _)) { st := s2; acc := a2 }; case (#err _) {} };
  switch (B.quoteWithdrawal(c, fee, 11 + k % 7)) { case (#ok q) { switch (B.requestWithdrawal(acc, q)) { case (#ok a2) { acc := a2;
      let o : B.Order = { id = k; owner; gross = q.gross; fee = q.fee; net = q.net; created = 0; status = #Pending };
      switch (B.settleOrder(acc, o, if (k % 2 == 0) #Settled "t" else #Failed "f")) { case (#ok(a3, _)) { acc := a3 }; case (#err _) { assert false } } }; case (#err _) {} } }; case (#err _) {} };
  assert B.balanced(acc);
};
assert acc.converted > 0 and acc.pending == 0;
Debug.print("BankTest ok");
