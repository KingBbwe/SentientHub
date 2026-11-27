#!/bin/sh
# Compile-checks every module and runs every Motoko test. Needs: npm i motoko; ./fetch-base.sh. Exit 1 on any failure.
cd "$(dirname "$0")"; rc=0
for f in Types Data Skills Character Rules Progression Economy Dice Sentient Bank Hub; do printf "check %-10s" $f; node check.js ../../sentient-economic-backend/src/$f.mo 0 | head -1; node check.js ../../sentient-economic-backend/src/$f.mo 0 | head -1 | grep -q "errors 0" || rc=1; done
for t in DataTest CharacterParity RulesParity ProgressionTest EconomyTest DiceTest SentientTest BankTest; do echo "-- $t"; node run.js ../../sentient-economic-backend/tests/$t.mo 2>&1 | grep -E "ok|MISMATCH|COMPILE|FAILED" | head -5 | tee /tmp/t.out; grep -q " ok" /tmp/t.out || rc=1; done
exit $rc
