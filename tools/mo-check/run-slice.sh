#!/bin/sh
# Move 7: the vertical slice in one command, from a clean checkout (needs: npm i motoko; ./fetch-base.sh; identify-eweself checked out next to this repo).
cd "$(dirname "$0")" && { [ -e node_modules ] || npm i --silent motoko >/dev/null 2>&1; } && node gen-slice.js >/dev/null && node run.js ../../sentient-economic-backend/tests/VerticalSlice.mo 2>&1 | grep -E "^[0-9]+\.|SLICE|COMPILE|error" 
