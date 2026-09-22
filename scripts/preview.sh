#!/bin/bash
set -eu
cd "$(dirname "$0")/.."
if [[ -n "${DEEPSEEK_API_KEY:-}" ]]; then
  exec node server/proxy.mjs
fi
IFS= read -r -s -p 'DeepSeek key (hidden; Enter for offline mode): ' lunar_provider_key
printf '\n'
if [[ -z "$lunar_provider_key" ]]; then
  exec node server/proxy.mjs
fi
printf '%s\n' "$lunar_provider_key" | node server/proxy.mjs --key-stdin
