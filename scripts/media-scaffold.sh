#!/usr/bin/env bash
#
# media-scaffold.sh — prepare a local repo checkout for README media.
#
# Creates the assets/ folder tree, writes an assets/MEDIA-NEEDED.md checklist,
# and prints a ready-to-paste badge row for the repo. Does NOT edit README or
# commit anything — the skill handles wiring and the user handles the commit.
#
# Usage:
#   media-scaffold.sh --dir /path/to/repo/checkout --slug owner/repo
#
set -euo pipefail

DIR="$(pwd)"
SLUG=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dir)  DIR="$2";  shift ;;
    --slug) SLUG="$2"; shift ;;
    *) echo "media-scaffold.sh: unknown arg: $1" >&2; exit 2 ;;
  esac
  shift
done

if [[ ! -d "$DIR" ]]; then
  echo "media-scaffold.sh: not a directory: $DIR" >&2
  exit 2
fi

mkdir -p "${DIR}/assets/screenshots" "${DIR}/assets/certs"

cat > "${DIR}/assets/MEDIA-NEEDED.md" <<'EOF'
# Media checklist

Drop files into `assets/` and mark each done. The skill wires them into the
README with proper alt text and sizing. Delete this file once complete.

## Automated (the skill produces these)
- [ ] `assets/banner.png` — 1280×640, generated via fal.ai (also usable as the
      GitHub social preview image)
- [ ] `assets/screenshots/hero-1440.png` — captured from the live site if the
      repo has a homepage
- [ ] Badge row — deterministic shields.io badges (no file needed)

## You provide (only what applies)
- [ ] `assets/demo.gif` — 5–15s screen recording of the main flow (< 5 MB)
- [ ] `assets/screenshots/feature-1.png` — key screen
- [ ] `assets/screenshots/feature-2.png` — second key screen
- [ ] `assets/certs/cert-1.png` — award/certificate (optional)
EOF

echo "Scaffolded: ${DIR}/assets/ (screenshots/, certs/, MEDIA-NEEDED.md)"

if [[ -n "$SLUG" ]]; then
  echo
  echo "Badge row for ${SLUG} (paste under the tagline):"
  cat <<EOF
<p align="center">
  <img src="https://img.shields.io/github/license/${SLUG}" alt="License">
  <img src="https://img.shields.io/github/stars/${SLUG}" alt="Stars">
  <img src="https://img.shields.io/github/last-commit/${SLUG}" alt="Last commit">
</p>
EOF
fi
