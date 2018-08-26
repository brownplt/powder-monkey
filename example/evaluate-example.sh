#!/bin/bash

PYRET="$(realpath "${1:-$PYRET}")"

for DIR1 in corpus/* ; do
  for DIR2 in corpus/* ; do
    echo "$(realpath "$DIR1/code.arr")"  \
         "$(realpath "$DIR2/tests.arr")" \
         "$(realpath "result")/$(basename "$DIR1")_$(basename "$DIR2")"
  done
done | ../evaluator-many.sh "$PYRET"
