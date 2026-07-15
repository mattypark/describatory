#!/usr/bin/env bash
#
# fetch-repo.sh — pull the signal needed to describe one repo.
#
# Outputs a single JSON object: languages, README (raw, truncated), and
# whether the repo already has a custom social-preview image.
#
# Usage:
#   fetch-repo.sh OWNER/REPO [--readme-chars N]
#
set -euo pipefail

README_CHARS=8000

if [[ $# -lt 1 ]]; then
  echo "fetch-repo.sh: need OWNER/REPO" >&2
  exit 2
fi
SLUG="$1"; shift

while [[ $# -gt 0 ]]; do
  case "$1" in
    --readme-chars) README_CHARS="$2"; shift ;;
    *) echo "fetch-repo.sh: unknown arg: $1" >&2; exit 2 ;;
  esac
  shift
done

if ! command -v gh >/dev/null 2>&1; then
  echo "fetch-repo.sh: 'gh' not found. Install: brew install gh" >&2
  exit 127
fi

OWNER="${SLUG%%/*}"
REPO="${SLUG##*/}"

# Languages (byte counts). Empty object on failure.
LANGUAGES="$(gh api "/repos/${SLUG}/languages" 2>/dev/null || echo '{}')"

# README as raw text; empty string if the repo has none.
README="$(gh api "/repos/${SLUG}/readme" \
  -H "Accept: application/vnd.github.raw+json" 2>/dev/null | head -c "$README_CHARS" || true)"

# Custom social image? (read-only; GraphQL is the only source).
CUSTOM_SOCIAL="$(gh api graphql -f query="
  query { repository(owner: \"${OWNER}\", name: \"${REPO}\") {
    usesCustomOpenGraphImage
  } }" --jq '.data.repository.usesCustomOpenGraphImage' 2>/dev/null || echo "null")"

# Assemble via jq so the README is safely JSON-escaped.
jq -n \
  --arg slug "$SLUG" \
  --argjson languages "$LANGUAGES" \
  --arg readme "$README" \
  --argjson custom_social "${CUSTOM_SOCIAL:-null}" \
  '{
    full_name: $slug,
    languages: $languages,
    readme: $readme,
    uses_custom_social_image: $custom_social
  }'
