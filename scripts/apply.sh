#!/usr/bin/env bash
#
# apply.sh — write new metadata to one repo.
#
# Writes are serialized and rate-limit aware. Without --apply it prints the
# calls it WOULD make and exits 0 (dry run is the default, on purpose).
#
# Usage:
#   apply.sh OWNER/REPO \
#     --description "The X for Y." \
#     [--homepage "https://..."] \
#     [--topics "a,b,c"] \
#     [--apply]
#
# Topics are a FULL REPLACE (PUT). Pass --topics "" to clear all topics.
# Omit --topics entirely to leave topics untouched.
#
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "apply.sh: need OWNER/REPO" >&2
  exit 2
fi
SLUG="$1"; shift

DESCRIPTION=""
HOMEPAGE=""
TOPICS=""
SET_DESC=false
SET_HOME=false
SET_TOPICS=false
DO_APPLY=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --description) DESCRIPTION="$2"; SET_DESC=true; shift ;;
    --homepage)    HOMEPAGE="$2";    SET_HOME=true; shift ;;
    --topics)      TOPICS="$2";      SET_TOPICS=true; shift ;;
    --apply)       DO_APPLY=true ;;
    *) echo "apply.sh: unknown arg: $1" >&2; exit 2 ;;
  esac
  shift
done

if ! command -v gh >/dev/null 2>&1; then
  echo "apply.sh: 'gh' not found. Install: brew install gh" >&2
  exit 127
fi

# gh api wrapper with retry/backoff on secondary rate limits (403/429).
gh_write() {
  local attempt=1 max=4 delay=2
  while true; do
    if gh api "$@"; then
      return 0
    fi
    if [[ $attempt -ge $max ]]; then
      echo "apply.sh: write failed after ${max} attempts: gh api $*" >&2
      return 1
    fi
    echo "apply.sh: write throttled/failed, retry ${attempt}/${max} in ${delay}s..." >&2
    sleep "$delay"
    delay=$(( delay * 2 ))
    attempt=$(( attempt + 1 ))
  done
}

# --- description + homepage (single PATCH) ---
if [[ "$SET_DESC" == true || "$SET_HOME" == true ]]; then
  PATCH_ARGS=(--method PATCH "/repos/${SLUG}")
  [[ "$SET_DESC" == true ]] && PATCH_ARGS+=(-f "description=${DESCRIPTION}")
  [[ "$SET_HOME" == true ]] && PATCH_ARGS+=(-f "homepage=${HOMEPAGE}")

  if [[ "$DO_APPLY" == true ]]; then
    gh_write "${PATCH_ARGS[@]}" --silent
    echo "apply.sh: [${SLUG}] description/homepage updated"
    sleep 1
  else
    echo "DRY RUN [${SLUG}] would PATCH: description='${DESCRIPTION}' homepage='${HOMEPAGE}'"
  fi
fi

# --- topics (full replace via PUT) ---
if [[ "$SET_TOPICS" == true ]]; then
  PUT_ARGS=(--method PUT "/repos/${SLUG}/topics")
  if [[ -n "$TOPICS" ]]; then
    IFS=',' read -ra ARR <<< "$TOPICS"
    for t in "${ARR[@]}"; do
      t="$(echo "$t" | tr '[:upper:]' '[:lower:]' | xargs)"  # lowercase + trim
      [[ -n "$t" ]] && PUT_ARGS+=(-f "names[]=${t}")
    done
  else
    PUT_ARGS+=(-f "names[]=")  # placeholder; cleared below via raw field
  fi

  if [[ "$DO_APPLY" == true ]]; then
    if [[ -n "$TOPICS" ]]; then
      gh_write "${PUT_ARGS[@]}" --silent
    else
      # Clear all topics: send an empty names array.
      gh_write --method PUT "/repos/${SLUG}/topics" \
        --input - --silent <<< '{"names":[]}'
    fi
    echo "apply.sh: [${SLUG}] topics updated"
    sleep 1
  else
    echo "DRY RUN [${SLUG}] would PUT topics: '${TOPICS}'"
  fi
fi

if [[ "$SET_DESC" == false && "$SET_HOME" == false && "$SET_TOPICS" == false ]]; then
  echo "apply.sh: nothing to change for ${SLUG}" >&2
fi
