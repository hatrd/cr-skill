#!/usr/bin/env bash
set -euo pipefail

output_file="${CODERABBIT_OUTPUT:-coderabbit_prompt_only.txt}"

args=("$@")
need_prompt_only=1
for arg in "${args[@]}"; do
  if [[ "$arg" == "--prompt-only" ]]; then
    need_prompt_only=0
    break
  fi
done

if [[ $need_prompt_only -eq 1 ]]; then
  args=(--prompt-only "${args[@]}")
fi

coderabbit "${args[@]}" |& tee "$output_file"
printf '\nSaved CodeRabbit output to: %s\n' "$output_file" >&2
