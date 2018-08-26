#!/bin/bash

# CHANGE THIS AS NEEDED
export PATH="/gpfs/main/home/jswrenn/.nvm/versions/node/v9.2.0/bin:$PATH"

# Evaluate a given implementation against a given test.
# Arguments:
# 1 or $IMPL      path to impl
# 2 or $TEST      path to test
# 3 or $OUTPUT    path to output folder
# 4 or $PYRET     path to pyret folder
# 5 or $PREHOOK   (optional) script to run after copying $TEST to $OUTPUT

IMPL="$(realpath "${1:-$IMPL}")"
TEST="$(realpath "${2:-$TEST}")"
OUTPUT="${3:-$OUTPUT}"
PYRET="$(realpath "${4:-$PYRET}")"
PREHOOK="$(realpath "${5:-$PREHOOK}" || echo "")"

if [ ! -f "$IMPL" ]; then echo "ERROR: No such impl: $IMPL" >&2 || exit 1; fi
if [ ! -f "$TEST" ]; then echo "ERROR: No such test: $TEST" >&2 || exit 1; fi
if [ ! -d "$OUTPUT" ]; then mkdir -p "$OUTPUT" >&2 || exit 1; fi
if [ ! -d "$PYRET" ]; then echo "ERROR: No pyret folder: $PYRET" >&2 || exit 1; fi

echo "$OUTPUT"

function report_error() {
  /gpfs/main/home/jswrenn/bin/jq                                     \
       --null-input                                                  \
       --arg IMPL "$IMPL"                                            \
       --arg TEST "$TEST"                                            \
       --arg ERROR "$1"                                              \
       '{ impl: $IMPL, tests: $TEST, result : {Err : $ERROR} }'      \
       >"$OUTPUT/results.json" 2>>"$OUTPUT/error.txt"
}

# Assume an error has accored.
report_error "Unknown"

# Copy tests file to results directory.
cp "$TEST" "$OUTPUT/tests.arr"

if [ -f "$PREHOOK" ]; then
  ( cd "$OUTPUT" && bash "$PREHOOK" )
fi

# Compile and Execute
cd "$PYRET" || exit 1
export NODE_PATH="$(realpath ./node_modules)"
# Compile
# For some reason, this is printing the absolute path to pyret-lang to stdout...
node build/phaseA/pyret.jarr -no-display-progress                       \
   --build-runnable   "$(realpath --relative-to=. "$OUTPUT/tests.arr")" \
   --outfile          "$(realpath --relative-to=. "$OUTPUT")/tests.js"  \
   --standalone-file  "../runner.js"                                    \
   --builtin-js-dir   "src/js/trove/"                                   \
   --builtin-arr-dir  "src/arr/trove"                                   \
   --require-config   "src/scripts/standalone-configA.json"             \
  >/dev/null 2>>"$OUTPUT/error.txt"

if [ ! -f "$OUTPUT/tests.js" ]; then
  echo "Compilation failed: $IMPL $TEST" 2>>"$OUTPUT/error.txt"
  report_error "Compilation"
  exit 0
fi

# If exit-after-compilation is true, then exit
if [ "$COMP" = true ] ; then
  exit 0
fi

function finish() {
  # if evaluation produced output that's valid json...
  if [ -s "$OUTPUT/raw.json" ] &&  jq '.' "$OUTPUT/raw.json" >/dev/null ; then
    jq \
      --compact-output \
      --arg IMPL "$IMPL" \
      --arg TEST "$TEST" \
      '{ impl: $IMPL, tests: $TEST, result: {Ok: (. |= map(select(.loc | contains("tests.arr"))))} }'  \
      "$OUTPUT/raw.json" \
        >"$OUTPUT/results.json" 2>>"$OUTPUT/error.txt"
  fi
  rm -f "$OUTPUT/tests.js" "$OUTPUT/tests.arr"
  if [ ! -s "$OUTPUT/error.txt" ] ; then
    rm -f "$OUTPUT/error.txt"
  fi
}

trap finish EXIT

# Assume a timeout occurs
report_error "Timeout"

# Run
node "$(realpath --relative-to=. "$OUTPUT")/tests.js" \
  2>>"$OUTPUT/error.txt" >"$OUTPUT/raw.json"

if [ -s "$OUTPUT/error.txt" ] ; then
  if grep -q "memory" "$OUTPUT/error.txt"; then
    report_error "OutOfMemory"
    exit 0
  else
    report_error "Runtime"
    exit 0
  fi
fi

exit 0
