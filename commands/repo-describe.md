---
description: Learn your whole GitHub, then rewrite every repo's About description + topics in one consistent voice — code-informed, review-before-push. Add --profile for your bio + profile README, or --media to enrich a repo's README.
argument-hint: "[owner/repo] [--apply] [--profile] [--media] [--public-only] [--include-forks] [--include-archived]"
---

# /repo-describe

You are running the **repo-describe** tool. It reads the user's GitHub
repositories, studies each one's actual code, and drafts a professional
short description + topics for the repo's "About" sidebar — then applies
them only after the user approves.

**YOU are the model writing the descriptions.** Read the repo signal and
write the copy yourself using the formula. Do not call any external LLM.

Scripts live at `~/.claude/repo-describe/scripts/`. Reference playbooks:
- `~/.claude/repo-describe/reference/formula.md` — the repo-description formula.
- `~/.claude/repo-describe/reference/profile.md` — account identity, bio, profile README.
- `~/.claude/repo-describe/reference/media.md` — README media (banner/screenshots/badges).

Arguments passed: `$ARGUMENTS`

**Routing:**
- `--profile` → run **Profile mode**: learn the whole account, then write the
  bio + profile README. (See section below.)
- `--media` → run **Media mode** on ONE repo (needs a local checkout; edits
  README.md). (See section below.)
- otherwise → the About-metadata flow below, which ALWAYS starts by learning
  the account (Step 1.5) so every description shares one voice.

## Step 0 — Preflight

1. Read `~/.claude/repo-describe/reference/formula.md` in full. Every draft
   must follow it.
2. Check `gh`:
   ```bash
   command -v gh >/dev/null && gh auth status
   ```
   If `gh` is missing, STOP and tell the user:
   > Install the GitHub CLI first: `brew install gh`, then `gh auth login`.
   The token needs **Administration: write** (fine-grained PAT) or the
   `repo` scope (classic) to edit repo metadata — Contents scope is NOT
   enough. Do not proceed until auth is confirmed.

## Step 1 — Parse arguments

- No `owner/repo` given → operate over ALL owned repos.
- An `owner/repo` given → operate on that single repo only.
- `--apply` → after the review table, you MAY push (still requires the
  user's explicit "yes" in chat). Without `--apply`, this is a dry run and
  you must NOT push under any circumstance.
- `--public-only`, `--include-forks`, `--include-archived` → pass through to
  the list script.

## Step 2 — Enumerate

Single repo: skip listing, just fetch it.
Otherwise:
```bash
~/.claude/repo-describe/scripts/list-repos.sh [--public-only] [--include-forks] [--include-archived]
```
This emits one JSON object per line. If the list is large (>20 repos), tell
the user how many were found and process them in batches, reporting progress.

## Step 2.5 — Learn the account (do this before drafting)

Read `~/.claude/repo-describe/reference/profile.md` section 1. Pull account
signal:
```bash
~/.claude/repo-describe/scripts/fetch-user.sh
```
Combine it with the full repo list from Step 2 and synthesize a short
**developer identity** (what they build, dominant stack, signal projects,
voice). Show it to the user in 3–5 sentences and let them correct it.

Carry this identity into every per-repo draft in Step 4 so all descriptions
share one voice and position sensibly against each other (e.g. don't describe
three of their projects as "the" platform for the same thing). For a
single-repo run, still fetch the user so the one description fits their
portfolio.

## Step 3 — Gather signal per repo

For each target repo:
```bash
~/.claude/repo-describe/scripts/fetch-repo.sh OWNER/REPO
```
You now have: current description/topics/homepage (from step 2), the
`languages` map, the raw `readme`, and `uses_custom_social_image`.

## Step 4 — Draft (this is the important part)

For each repo, using the formula, draft:
- **description** — 30–70 chars, "The X for Y." or "A [adj] [category] for
  [use-case]." No hype words. No emoji unless the project has a real mascot
  identity. Describe what the CODE is, not a paraphrase of the README's first
  line. If the README is empty, infer purpose from languages + file names +
  repo name.
- **topics** — 8–14, lowercase, spanning the 5 buckets (language, own name,
  domain, ecosystem peers, use-case). Reuse good existing topics; don't churn.
- **homepage** — keep the existing one if valid; suggest one only if the
  README clearly links a live site/docs. Never invent a URL. Never point at
  the repo itself.

Mark a repo **"already good — no change"** when its current description
already fits the formula, rather than rewriting for the sake of it.

Respect skip rules: forks and archived repos are excluded unless the user
opted in.

## Step 5 — Review table

Present a compact table the user can scan. One row per repo:

| Repo | Current → Proposed description | Topics Δ | Notes |
|------|--------------------------------|----------|-------|

- Show the OLD and NEW description together so the change is obvious.
- For topics, show only additions/removals, not the full list.
- In Notes, flag: "no custom social image" (from
  `uses_custom_social_image == false`), "README empty", "already good", etc.

Then STOP and ask the user to approve, edit specific rows, or cancel.
Never push before this approval — even with `--apply`.

## Step 6 — Apply (only after explicit approval)

For each approved repo, serialized (one at a time):
```bash
~/.claude/repo-describe/scripts/apply.sh OWNER/REPO \
  --description "The X for Y." \
  --homepage "https://..." \
  --topics "a,b,c" \
  --apply
```
- Omit `--homepage` to leave it untouched; omit `--topics` to leave topics
  untouched.
- The script rate-limits itself. If many repos, keep the user posted on
  progress. Honor the 500-content-writes/hour ceiling — for very large
  accounts (>200 repos) do it in sessions.

## Step 7 — Report

Summarize: repos updated, repos left unchanged (and why), and a bullet list
of repos still missing a **custom social preview image** (there is no API to
set it — the user uploads those manually via Settings → General → Social
preview). Offer to design those cards next if they want.

---

# Profile mode (`--profile`)

Learn the whole account, then write the two account-level surfaces: the **bio**
(line under your name) and the **profile README** (the `USERNAME/USERNAME`
repo shown on your profile page). Read
`~/.claude/repo-describe/reference/profile.md` in full first.

## P1 — Learn
```bash
~/.claude/repo-describe/scripts/fetch-user.sh
~/.claude/repo-describe/scripts/list-repos.sh
```
Synthesize the developer identity (profile.md section 1). If the About pass
already ran this session, reuse that identity. Show it and let the user correct
it before writing.

## P2 — Draft the bio
≤ 160 chars, concrete, no fluff words (profile.md section 2). Show current →
proposed.

## P3 — Draft the profile README
Follow profile.md section 3: header, "what I build", a **featured-projects
table** built from the 3–6 signal repos (reuse the per-repo descriptions so the
profile and each repo agree), real tech stack, optional stats, real links only.
Write it to a local file, e.g. `/tmp/repo-describe/PROFILE.md`, and show the
user the full rendered content.

Note whether the `USERNAME/USERNAME` repo already exists (from
`fetch-user.sh`'s `profile_repo_exists`). If it doesn't, tell the user P4 will
**create a new public repo** — get explicit consent for that specifically.

## P4 — Apply (only after explicit approval)
```bash
~/.claude/repo-describe/scripts/apply-profile.sh \
  --bio "..." \
  --readme-file /tmp/repo-describe/PROFILE.md \
  --apply
```
- Omit `--bio` or `--readme-file` to write only one of them.
- Writing the bio and committing the profile README are real writes; creating
  the profile repo is a public action. Never run with `--apply` before the user
  says yes to both the content and (if needed) the repo creation.

## P5 — Report
Confirm what was written. Offer to run the full About pass next (or vice-versa)
so repos and profile stay in sync.

---

# Media mode (`--media`)

Enrich ONE repo's README with a banner, screenshots, badges, and optional
video/certificates. Read `~/.claude/repo-describe/reference/media.md` in full
first — it defines the anatomy, acquisition methods, and exact markdown.

## M0 — Target + checkout
- Require a specific repo. If the user ran `--media` with no `owner/repo`, ask
  which one.
- Need a local working copy to edit README.md. If the user gives a local path,
  use it. Otherwise clone to a temp dir:
  `gh repo clone OWNER/REPO /tmp/repo-describe/REPO`.

## M0.5 — Ask what media the user has (do this first)
Before capturing/generating anything, ASK the user what they already have —
files, only links, or nothing — exactly as described in media.md's "Image
intake" section. Ideally 3+ images, but one good hero is fine and it's
optional. Route their answer (place files / use or download links / fall back
to capture+generate). Never assume they have nothing.

## M1 — Audit
Read the current README and `ls assets/` (if any). Decide which media slots
from the playbook this repo needs, based on what it IS (CLI → banner + terminal
GIF; web app → banner + UI screenshots; library → banner + badges + code
sample). Note what already exists so you don't duplicate.

## M2 — Scaffold
```bash
~/.claude/repo-describe/scripts/media-scaffold.sh --dir <checkout> --slug OWNER/REPO
```
Creates `assets/` tree, a `MEDIA-NEEDED.md` checklist, and prints the badge row.

## M3 — Acquire each slot (per media.md's three methods)
- **CAPTURE**: if the repo has a homepage, use the Claude-in-Chrome browser
  tools (load them via ToolSearch first) to screenshot the live site at 1440
  and 768, saved into `assets/screenshots/`.
- **GENERATE**: use `mcp__fal-ai__generate` to make the 1280×640 `banner.png`
  (and note it doubles as the social preview). Never generate fake screenshots.
- **REQUEST**: for demo recordings, certificates, or app screenshots you can't
  capture, STOP and give the user an exact numbered checklist of files to drop,
  then place each one after confirming its purpose. This is the "I need 3
  images from you" path.

## M4 — Wire the README
Insert the media using the exact markdown patterns from media.md: centered
banner, badge row (real badges only), hero, feature grid, and any
video/certs. Write real alt text for every image. Show the user a diff of the
README changes.

## M5 — Hand off (never auto-commit)
Report what was added and which files are still awaited from the user. Because
this modifies README.md and adds binary assets, STOP before committing and tell
the user the exact `git add`/`git commit`/`git push` commands to run
themselves — do not run them. Remind them the 1280×640 banner can also be
uploaded as the repo's social preview (Settings → General → Social preview).
