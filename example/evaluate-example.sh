#!/bin/bash

PYRET="$(realpath "${1:-$PYRET}")"

# Queue all pairwise matchups of impls and tests
for DIR1 in corpus/* ; do
  for DIR2 in corpus/* ; do
    echo "$(realpath "$DIR1/code.arr")"  \
         "$(realpath "$DIR2/tests.arr")" \
         "$(realpath "result")/$(basename "$DIR1")_$(basename "$DIR2")"
  done
done | ../evaluate/evaluate-many.sh "$PYRET" "prehook.sh"

# Coalesce results
jq --slurp '.' result/*/results.json \
  > result/results.json

