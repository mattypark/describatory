#!/usr/bin/env bash
#
# list-repos.sh — enumerate the authenticated user's repositories.
#
# Emits one compact JSON object per line (JSONL) with the fields the
# describer needs. Owner-affiliated repos only (public + private).
#
# Usage:
#   list-repos.sh [--include-forks] [--include-archived] [--public-only]
#
set -euo pipefail

INCLUDE_FORKS=false
INCLUDE_ARCHIVED=false
VISIBILITY="all"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --include-forks)    INCLUDE_FORKS=true ;;
    --include-archived) INCLUDE_ARCHIVED=true ;;
    --public-only)      VISIBILITY="public" ;;
    *) echo "list-repos.sh: unknown arg: $1" >&2; exit 2 ;;
  esac
  shift
done

if ! command -v gh >/dev/null 2>&1; then
  echo "list-repos.sh: 'gh' (GitHub CLI) not found. Install: brew install gh" >&2
  exit 127
fi

# Build a jq filter that applies the skip rules at the source.
FILTER='.[]'
[[ "$INCLUDE_FORKS"    == false ]] && FILTER="$FILTER | select(.fork == false)"
[[ "$INCLUDE_ARCHIVED" == false ]] && FILTER="$FILTER | select(.archived == false)"
FILTER="$FILTER | {
  full_name,
  name,
  owner: .owner.login,
  description,
  homepage,
  topics,
  language,
  private,
  fork,
  archived,
  stargazers_count,
  pushed_at
}"

gh api --paginate \
  "/user/repos?affiliation=owner&visibility=${VISIBILITY}&per_page=100&sort=pushed" \
  --jq "$FILTER" -c
