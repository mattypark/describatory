#!/usr/bin/env bash
#
# apply-profile.sh — write account-level metadata.
#
#   --bio "..."          update the profile bio (PATCH /user)
#   --readme-file PATH    write PATH as the profile README (LOGIN/LOGIN repo);
#                         creates the repo if it does not exist
#   --apply               actually write (default is dry run)
#
# Usage:
#   apply-profile.sh --login LOGIN [--bio "..."] [--readme-file ./PROFILE.md] [--apply]
#
set -euo pipefail

LOGIN=""
BIO=""
README_FILE=""
SET_BIO=false
SET_README=false
DO_APPLY=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --login)       LOGIN="$2"; shift ;;
    --bio)         BIO="$2"; SET_BIO=true; shift ;;
    --readme-file) README_FILE="$2"; SET_README=true; shift ;;
    --apply)       DO_APPLY=true ;;
    *) echo "apply-profile.sh: unknown arg: $1" >&2; exit 2 ;;
  esac
  shift
done

if ! command -v gh >/dev/null 2>&1; then
  echo "apply-profile.sh: 'gh' not found. Install: brew install gh" >&2
  exit 127
fi
[[ -z "$LOGIN" ]] && LOGIN="$(gh api /user --jq .login)"

# --- bio ---
if [[ "$SET_BIO" == true ]]; then
  if [[ "$DO_APPLY" == true ]]; then
    gh api --method PATCH /user -f "bio=${BIO}" --silent
    echo "apply-profile.sh: bio updated"
  else
    echo "DRY RUN would PATCH /user bio='${BIO}'"
  fi
fi

# --- profile README ---
if [[ "$SET_README" == true ]]; then
  [[ -f "$README_FILE" ]] || { echo "apply-profile.sh: no such file: $README_FILE" >&2; exit 2; }

  REPO="${LOGIN}/${LOGIN}"
  EXISTS=false
  gh api "/repos/${REPO}" >/dev/null 2>&1 && EXISTS=true

  if [[ "$DO_APPLY" != true ]]; then
    echo "DRY RUN would write ${README_FILE} to ${REPO}/README.md (repo exists: ${EXISTS})"
  else
    if [[ "$EXISTS" != true ]]; then
      echo "apply-profile.sh: creating profile repo ${REPO} (public)..."
      gh repo create "$REPO" --public \
        --description "Profile README" >/dev/null
    fi

    # Existing README sha (needed to update in place); empty if none.
    SHA="$(gh api "/repos/${REPO}/contents/README.md" --jq .sha 2>/dev/null || true)"
    CONTENT_B64="$(base64 < "$README_FILE" | tr -d '\n')"

    ARGS=(--method PUT "/repos/${REPO}/contents/README.md"
          -f "message=Update profile README (describatory)"
          -f "content=${CONTENT_B64}")
    [[ -n "$SHA" ]] && ARGS+=(-f "sha=${SHA}")

    gh api "${ARGS[@]}" --silent
    echo "apply-profile.sh: profile README written to ${REPO}"
  fi
fi

if [[ "$SET_BIO" == false && "$SET_README" == false ]]; then
  echo "apply-profile.sh: nothing to do (pass --bio and/or --readme-file)" >&2
fi
