---
description: Read every GitHub repo you own and rewrite its About description + topics professionally, code-informed, with review-before-push.
argument-hint: "[owner/repo] [--apply] [--public-only] [--include-forks] [--include-archived]"
---

# /repo-describe

You are running the **repo-describe** tool. It reads the user's GitHub
repositories, studies each one's actual code, and drafts a professional
short description + topics for the repo's "About" sidebar — then applies
them only after the user approves.

**YOU are the model writing the descriptions.** Read the repo signal and
write the copy yourself using the formula. Do not call any external LLM.

Scripts live at `~/.claude/repo-describe/scripts/`.
The description formula is at `~/.claude/repo-describe/reference/formula.md`.

Arguments passed: `$ARGUMENTS`

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
