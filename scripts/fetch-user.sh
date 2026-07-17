#!/usr/bin/env bash
#
# fetch-user.sh — read the authenticated user's account-level signal.
#
# Outputs a single JSON object: profile fields (bio, name, blog, company,
# location, follower/repo counts) plus whether the special profile-README
# repo (LOGIN/LOGIN) exists and its current README text.
#
# Usage: fetch-user.sh [--readme-chars N]
#
set -euo pipefail

README_CHARS=6000
while [[ $# -gt 0 ]]; do
  case "$1" in
    --readme-chars) README_CHARS="$2"; shift ;;
    *) echo "fetch-user.sh: unknown arg: $1" >&2; exit 2 ;;
  esac
  shift
done

if ! command -v gh >/dev/null 2>&1; then
  echo "fetch-user.sh: 'gh' not found. Install: brew install gh" >&2
  exit 127
fi

USER_JSON="$(gh api /user)"
LOGIN="$(echo "$USER_JSON" | jq -r '.login')"

# Does the profile-README repo (LOGIN/LOGIN) exist?
PROFILE_EXISTS=false
if gh api "/repos/${LOGIN}/${LOGIN}" >/dev/null 2>&1; then
  PROFILE_EXISTS=true
fi

# Its current README, if any.
PROFILE_README=""
if [[ "$PROFILE_EXISTS" == true ]]; then
  PROFILE_README="$(gh api "/repos/${LOGIN}/${LOGIN}/readme" \
    -H "Accept: application/vnd.github.raw+json" 2>/dev/null | head -c "$README_CHARS" || true)"
fi

echo "$USER_JSON" | jq \
  --arg profile_readme "$PROFILE_README" \
  --argjson profile_exists "$PROFILE_EXISTS" \
  '{
    login, name, bio, blog, company, location,
    followers, following, public_repos, created_at,
    profile_repo_exists: $profile_exists,
    profile_readme: $profile_readme
  }'
