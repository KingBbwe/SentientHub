#!/bin/sh
# Downloads the Motoko base modules that main.mo imports (and their imports) into ./base, for check.js.
set -e
cd "$(dirname "$0")"; mkdir -p base; cd base
B=https://raw.githubusercontent.com/dfinity/motoko-base/master/src
for m in Result HashMap Text Principal Time Random Nat8 Array Option Nat Int Float Hash Buffer Iter Order; do [ -f $m.mo ] || curl -sf -o $m.mo $B/$m.mo; done
for r in 1 2 3 4 5 6; do
  n=0
  for m in $(grep -h '^import' *.mo | grep -o 'import [A-Za-z0-9_]* "[A-Za-z0-9_]*"' | sed 's/.*"\(.*\)"/\1/' | sort -u); do
    [ -f $m.mo ] || { curl -sf -o $m.mo $B/$m.mo && n=$((n+1)); }
  done
  [ $n = 0 ] && break
done
