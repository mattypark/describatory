#!/usr/bin/env bash
#
# install.sh — one-command setup for repo-describe / describatory.
#
# Does everything a new user needs:
#   1. Ensures `gh` (GitHub CLI) and `jq` are installed.
#   2. Logs `gh` into GitHub (browser flow) if not already.
#   3. Installs the slash command + scripts for Claude Code.
#
# Works on macOS (Homebrew) and Linux (apt/dnf/pacman). For Cursor or any
# other agent, see docs/USING-WITH-OTHER-TOOLS.md — the scripts are portable.
#
# Re-run any time to update.
#
set -euo pipefail

SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="${HOME}/.claude"
DEST="${CLAUDE_DIR}/repo-describe"

say()  { printf '\033[1;36m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m!  \033[0m %s\n' "$*"; }
die()  { printf '\033[1;31mx  \033[0m %s\n' "$*" >&2; exit 1; }

# --- detect a package manager ---------------------------------------------
pkg_install() {
  local pkg="$1"
  if command -v brew >/dev/null 2>&1; then brew install "$pkg"
  elif command -v apt-get >/dev/null 2>&1; then sudo apt-get update && sudo apt-get install -y "$pkg"
  elif command -v dnf >/dev/null 2>&1; then sudo dnf install -y "$pkg"
  elif command -v pacman >/dev/null 2>&1; then sudo pacman -S --noconfirm "$pkg"
  else return 1; fi
}

ensure_tool() {
  local bin="$1" pkg="${2:-$1}"
  if command -v "$bin" >/dev/null 2>&1; then
    say "$bin already installed."
    return 0
  fi
  warn "$bin not found."
  printf "Install %s now? [Y/n] " "$pkg"; read -r ans
  case "${ans:-Y}" in
    [nN]*) die "$bin is required. Install it, then re-run ./install.sh" ;;
  esac
  pkg_install "$pkg" || die "Could not auto-install $pkg. Install it manually: https://cli.github.com (gh) / https://jqlang.github.io/jq (jq)"
  say "$bin installed."
}

# --- 1. dependencies -------------------------------------------------------
say "Checking dependencies..."
ensure_tool gh gh
ensure_tool jq jq

# --- 2. GitHub auth --------------------------------------------------------
if gh auth status >/dev/null 2>&1; then
  say "GitHub CLI already authenticated."
else
  warn "Not logged into GitHub."
  say  "Starting login (browser). Choose: GitHub.com -> HTTPS -> Login with a web browser."
  gh auth login || die "gh auth login failed. Re-run ./install.sh when ready."
fi

# --- 3. install the command + scripts -------------------------------------
say "Installing command and scripts..."
mkdir -p "${CLAUDE_DIR}/commands" "${DEST}/scripts" "${DEST}/reference"
cp "${SRC_DIR}/commands/repo-describe.md" "${CLAUDE_DIR}/commands/repo-describe.md"
cp "${SRC_DIR}/scripts/"*.sh              "${DEST}/scripts/"
cp "${SRC_DIR}/reference/"*.md            "${DEST}/reference/"
chmod +x "${DEST}/scripts/"*.sh

echo
say "Done. Installed:"
echo "  command : ${CLAUDE_DIR}/commands/repo-describe.md"
echo "  scripts : ${DEST}/scripts/"
echo "  formula : ${DEST}/reference/"
echo
say "In Claude Code, run:  /repo-describe"
echo "  (dry run over all your repos — nothing is pushed until you approve)"
echo
echo "Using Cursor or another agent? See docs/USING-WITH-OTHER-TOOLS.md"
