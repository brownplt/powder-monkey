#!/bin/bash

declare -a IMPLS=(corpus/{instructor-authored/wheats,student-authored/impls}/*)
declare -a TESTS=(corpus/student-authored/tests/*)

# Before doing a full run, it's a good idea to verify that student
# submissions are in a runnable state.
# Verify implementations by making sure they can be compiled.
# Verify test suites by making sure they can be run against (though
# not necessarily actually pass) one of the wheats.
# <TODO>

# Queue all pairwise matchups of impls and tests
for IMPL in ${IMPLS[@]} ; do
  for TEST in ${TESTS[@]};  do
    echo "$(realpath "$IMPL")"  \
         "$(realpath "$TEST")" \
         "$(realpath "result")/$(basename "$TEST")_$(basename "$IMPL")"
  done
done | /home/jswrenn/projects/powder-monkey/evaluate/evaluate-many.sh "prehook.sh"

# Coalesce results
jq --slurp '.' result/*/results.json \
  > result/results.json

