# mo-check

Type-checks `sentient-economic-backend/main.mo` without dfx, using the `motoko` npm package.

    cd tools/mo-check && npm i motoko && ./fetch-base.sh && node check.js ../../sentient-economic-backend/main.mo [maxLinesToShow]

Prints the diagnostics count and the first N diagnostics (line, code, message). Zero errors is the pass criterion.
Note: `mo.check` returns an array of diagnostics; the compiler stops at syntax errors before it reports type errors.
