---
description: Learn your whole GitHub, then rewrite EVERY repo's About description + topics in one consistent voice — code-informed, review-before-push. Add --profile for your bio + profile README. For a single repo, use /repo-describe-one.
argument-hint: "[--apply] [--profile] [--public-only] [--include-forks] [--include-archived]"
---

# /repo-describe — whole account

You are running **describatory** in account mode. It reads ALL of the user's
repositories, learns who they are as a developer, and rewrites every repo's
"About" description + topics in one consistent voice — applied only after the
user approves.

**YOU are the model writing the copy.** Read the signal and write it yourself
using the formula. Do not call any external LLM.

For a single repo (or README media), use **`/repo-describe-one`** instead.

Scripts live at `~/.claude/repo-describe/scripts/`. Reference playbooks:
- `~/.claude/repo-describe/reference/formula.md` — the repo-description formula.
- `~/.claude/repo-describe/reference/profile.md` — account identity, bio, profile README.

Arguments passed: `$ARGUMENTS`

**Routing:** if `--profile` is present, run **Profile mode** (bottom of this
file). Otherwise run the all-repos flow below.

## Step 0 — Preflight

1. Read `~/.claude/repo-describe/reference/formula.md` in full. Every draft
   must follow it.
2. Check `gh`:
   ```bash
   command -v gh >/dev/null && gh auth status
   ```
   If `gh` is missing or not logged in, STOP:
   > Install + log in first: `brew install gh`, then `gh auth login`.
   The token needs **Administration: write** (fine-grained PAT) or the `repo`
   scope — Contents scope is NOT enough.

## Step 1 — Parse arguments

- `--apply` → after the review table, you MAY push (still requires the user's
  explicit "yes" in chat). Without it, this is a dry run — push NOTHING.
- `--public-only`, `--include-forks`, `--include-archived` → pass to the list
  script.

## Step 2 — Enumerate all repos

```bash
~/.claude/repo-describe/scripts/list-repos.sh [--public-only] [--include-forks] [--include-archived]
```
One JSON object per line. Tell the user how many were found. If large (>20),
process in batches and report progress.

## Step 2.5 — Learn the account (before drafting)

Read `~/.claude/repo-describe/reference/profile.md` section 1. Pull account
signal:
```bash
~/.claude/repo-describe/scripts/fetch-user.sh
```
Combine with the repo list and synthesize a short **developer identity** (what
they build, dominant stack, signal projects, voice). Show it in 3–5 sentences
and let the user correct it. Carry it into every draft so all descriptions
share one voice and position sensibly against each other.

## Step 3 — Gather signal per repo

For each repo:
```bash
~/.claude/repo-describe/scripts/fetch-repo.sh OWNER/REPO
```
Gives languages, raw README, and `uses_custom_social_image`.

## Step 4 — Draft (the important part)

Per repo, using the formula + the learned identity:
- **description** — 30–70 chars, "The X for Y." or "A [adj] [category] for
  [use-case]." No hype, no emoji (unless real brand mascot). Describe what the
  CODE is. If the README is empty, infer from languages + file names + repo name.
- **topics** — 8–14, lowercase, across the 5 buckets. Reuse good existing ones.
- **homepage** — keep valid existing; suggest one only if the README clearly
  links a live site. Never invent a URL; never point at the repo itself.

Mark repos **"already good — no change"** rather than churning. Skip forks and
archived unless the user opted in.

## Step 5 — Review table

| Repo | Current → Proposed description | Topics Δ | Notes |
|------|--------------------------------|----------|-------|

Show OLD and NEW together. For topics show only additions/removals. In Notes
flag "no custom social image", "README empty", "already good". Then STOP and
ask the user to approve, edit rows, or cancel. Never push before this — even
with `--apply`.

## Step 6 — Apply (only after explicit approval)

Per approved repo, serialized:
```bash
~/.claude/repo-describe/scripts/apply.sh OWNER/REPO \
  --description "The X for Y." \
  --homepage "https://..." \
  --topics "a,b,c" \
  --apply
```
Omit `--homepage`/`--topics` to leave them untouched. The script rate-limits
itself. Keep the user posted on progress; for >200 repos, split across sessions
(500-content-writes/hour ceiling).

## Step 7 — Report

Repos updated, repos unchanged (and why), and a bullet list of repos still
missing a **custom social preview image** (no API to set it — user uploads
manually via Settings → General → Social preview). Offer `/repo-describe-one
--media` to design those, or `--profile` to update the bio + profile README.

---

# Profile mode (`--profile`)

Learn the whole account, then write the **bio** (line under the name) and the
**profile README** (the `USERNAME/USERNAME` repo shown on the profile page).
Read `~/.claude/repo-describe/reference/profile.md` in full first.

## P1 — Learn
```bash
~/.claude/repo-describe/scripts/fetch-user.sh
~/.claude/repo-describe/scripts/list-repos.sh
```
Synthesize the developer identity (profile.md section 1); reuse this session's
identity if the all-repos pass already ran it. Show it and let the user correct
it.

## P2 — Draft the bio
≤ 160 chars, concrete, no fluff (profile.md section 2). Show current → proposed.

## P3 — Draft the profile README
Follow profile.md section 3: header, "what I build", a **featured-projects
table** from the 3–6 signal repos (reuse the per-repo descriptions so profile
and repos agree), real tech stack, optional stats, real links only. Write it to
`/tmp/repo-describe/PROFILE.md` and show the full content. If the
`USERNAME/USERNAME` repo doesn't exist (`profile_repo_exists` false), warn that
P4 will **create a new public repo** — get explicit consent for that.

## P4 — Apply (only after explicit approval)
```bash
~/.claude/repo-describe/scripts/apply-profile.sh \
  --bio "..." \
  --readme-file /tmp/repo-describe/PROFILE.md \
  --apply
```
Omit `--bio` or `--readme-file` to write only one. These are real writes; repo
creation is public. Never `--apply` before the user says yes.

## P5 — Report
Confirm what was written. Offer to run the all-repos pass so repos and profile
stay in sync.
