---
description: Rewrite ONE repo's About description + topics professionally, code-informed and consistent with your GitHub voice. Add --media to enrich that repo's README with banner, screenshots, badges, and video. For all repos at once, use /repo-describe.
argument-hint: "owner/repo [--apply] [--media]"
---

# /repo-describe-one — single repo

You are running **describatory** on ONE repository. It reads the repo's code,
checks it against the user's overall GitHub voice, and rewrites its "About"
description + topics — applied only after the user approves.

**YOU are the model writing the copy.** Use the formula; no external LLM.

For every repo at once, or for the bio / profile README, use **`/repo-describe`**.

Scripts live at `~/.claude/repo-describe/scripts/`. Reference playbooks:
- `~/.claude/repo-describe/reference/formula.md` — the repo-description formula.
- `~/.claude/repo-describe/reference/media.md` — README media + image intake.

Arguments passed: `$ARGUMENTS`

**Routing:** if `--media` is present, run **Media mode** (bottom of this file).
Otherwise run the describe flow below.

## Step 0 — Preflight

1. Read `~/.claude/repo-describe/reference/formula.md` in full.
2. Check `gh`:
   ```bash
   command -v gh >/dev/null && gh auth status
   ```
   If missing/not logged in, STOP and tell the user to run `brew install gh`
   then `gh auth login` (needs Administration:write or `repo` scope).

## Step 1 — Parse arguments

- Require an `owner/repo`. If none given, ask which repo.
- `--apply` → after review, you MAY push (still needs explicit "yes"). Without
  it, dry run — push NOTHING.

## Step 2 — Gather signal

Fetch light account context (so the one description fits the user's portfolio
voice) and the repo itself:
```bash
~/.claude/repo-describe/scripts/fetch-user.sh
~/.claude/repo-describe/scripts/fetch-repo.sh OWNER/REPO
```
From fetch-user, note the developer identity briefly (don't over-invest for a
single repo). From fetch-repo you get languages, raw README, and
`uses_custom_social_image`. Also read the repo's current description/topics:
```bash
gh api /repos/OWNER/REPO --jq '{description, homepage, topics}'
```

## Step 3 — Draft

Using the formula + the user's voice:
- **description** — 30–70 chars, "The X for Y." or "A [adj] [category] for
  [use-case]." No hype, no emoji unless a real mascot. Describe what the CODE
  is; if README is empty, infer from languages + file names + repo name.
- **topics** — 8–14, lowercase, across the 5 buckets. Reuse good existing ones.
- **homepage** — keep valid existing; suggest one only if the README clearly
  links a live site. Never invent; never point at the repo.

If the current description already fits the formula, say "already good" rather
than churning it.

## Step 4 — Review

Show current → proposed description, topics diff, and flag "no custom social
image" / "README empty" if relevant. STOP and ask the user to approve, edit, or
cancel. Never push before this — even with `--apply`.

## Step 5 — Apply (only after explicit approval)

```bash
~/.claude/repo-describe/scripts/apply.sh OWNER/REPO \
  --description "The X for Y." \
  --homepage "https://..." \
  --topics "a,b,c" \
  --apply
```
Omit `--homepage`/`--topics` to leave them untouched.

## Step 6 — Report

Confirm what changed. If the repo lacks a custom social image, mention it (no
API — upload manually via Settings → General → Social preview, or run this
command with `--media` to generate a 1280×640 banner that doubles as one).

---

# Media mode (`--media`)

Enrich this repo's README with a banner, screenshots, badges, and optional
video/certificates. Read `~/.claude/repo-describe/reference/media.md` in full
first.

## M0 — Target + checkout
Need a local working copy to edit README.md. If the user gives a local path,
use it. Otherwise clone: `gh repo clone OWNER/REPO /tmp/repo-describe/REPO`.

## M0.5 — Ask what media the user has (do this first)
Before capturing/generating anything, ASK the user what they already have —
files, only links, or nothing — exactly as in media.md's "Image intake"
section. 3+ images is ideal but one good hero is fine and it's optional. Route
their answer (place files / use or download links / fall back to
capture+generate). Never assume they have nothing.

## M1 — Audit
Read the current README and `ls assets/`. Decide which media slots this repo
needs based on what it IS (CLI → banner + terminal GIF; web app → banner + UI
screenshots; library → banner + badges + code sample). Don't duplicate existing
media.

## M2 — Scaffold
```bash
~/.claude/repo-describe/scripts/media-scaffold.sh --dir <checkout> --slug OWNER/REPO
```
Creates `assets/` tree, a `MEDIA-NEEDED.md` checklist, and prints the badge row.

## M3 — Acquire each slot (media.md's three methods)
- **CAPTURE**: if the repo has a homepage, use the Claude-in-Chrome browser
  tools (load via ToolSearch first) to screenshot the live site at 1440 and
  768, into `assets/screenshots/`.
- **GENERATE**: use `mcp__fal-ai__generate` for the 1280×640 `banner.png` (also
  usable as the social preview). Never generate fake screenshots.
- **REQUEST**: for demos/certs/app screenshots you can't capture, give the user
  an exact numbered checklist and place each file after confirming its purpose.

## M4 — Wire the README
ALWAYS start the README with media.md's **Standard header block** (centered
title → rule → hook → badge row → punchline → rule) — it's the required house
style. Then insert the rest using the exact markdown from media.md (banner,
real badges only, hero, feature grid, video/certs) with real alt text, and
close with the optional license+contact footer. Show a diff.

## M5 — Hand off (never auto-commit)
Report what was added and what's still awaited. STOP before committing — give
the user the exact `git add`/`commit`/`push` commands to run themselves. Remind
them the 1280×640 banner can also be the repo's social preview.
