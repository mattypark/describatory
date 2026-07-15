#!/usr/bin/env bash
#
# install.sh — install repo-describe as a Claude Code slash command.
#
# Copies the command into ~/.claude/commands/ and the scripts + formula
# into ~/.claude/repo-describe/. Re-run any time to update.
#
set -euo pipefail

SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="${HOME}/.claude"
DEST="${CLAUDE_DIR}/repo-describe"

mkdir -p "${CLAUDE_DIR}/commands" "${DEST}/scripts" "${DEST}/reference"

cp "${SRC_DIR}/commands/repo-describe.md" "${CLAUDE_DIR}/commands/repo-describe.md"
cp "${SRC_DIR}/scripts/"*.sh            "${DEST}/scripts/"
cp "${SRC_DIR}/reference/formula.md"    "${DEST}/reference/formula.md"
chmod +x "${DEST}/scripts/"*.sh

echo "Installed:"
echo "  command : ${CLAUDE_DIR}/commands/repo-describe.md"
echo "  scripts : ${DEST}/scripts/"
echo "  formula : ${DEST}/reference/formula.md"
echo
echo "Next:"
echo "  1. brew install gh   (if not installed)"
echo "  2. gh auth login     (needs Administration:write / repo scope)"
echo "  3. In Claude Code, run:  /repo-describe"
