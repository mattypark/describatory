# repo-describe

**The Claude Code command that rewrites every GitHub repo's "About" — code-informed, in bulk, with review before push.**

Your READMEs get all the love. The one-line **description** in the About
sidebar — the line that shows in search results, your profile grid, and social
cards — is usually empty, stale, or generic. `repo-describe` fixes that across
*all* your repos in one command.

It reads each repo's actual code (README + languages), then Claude drafts a
professional description + topics using a formula reverse-engineered from
top-starred repos (react, next.js, supabase, langchain, …). Nothing is pushed
until you approve a review table.

## Why it's different

Existing tools each cover one slice:
- **README generators** (readme-ai, RepoAgent) write the README *file*, one
  repo at a time — never the About description.
- **Bulk tools** (all-repos, Terraform) edit all repos at once — but *you* type
  the strings; no AI.
- **Topic scripts** are tiny hobby projects.

Nothing does **code-informed + About description + bulk + auto-push**.
That's the gap this fills.

## How it works

```
/repo-describe                 # dry run over all owned repos → review table
/repo-describe owner/repo      # one repo
/repo-describe --apply         # review, approve in chat, then push
```

Flags: `--public-only`, `--include-forks`, `--include-archived`.

1. **Enumerate** your repos via `gh`.
2. **Read** each repo's README + languages.
3. **Draft** description (30–70 chars, no hype words) + 8–14 topics — *Claude
   writes these; no external API key needed.*
4. **Review** — you see a `current → proposed` table and approve/edit/cancel.
5. **Apply** — serialized, rate-limit aware writes via the GitHub API.
6. **Report** — including which repos still need a custom social image (that
   one's manual — GitHub exposes no API for it).

## The description formula

- **Length 30–70 chars.** GitHub truncates longer.
- **"The [X] for [Y]."** (category claim) or **"A [adj] [category] for
  [use-case]."** (noun phrase). Never verb-first.
- One real differentiator word; **zero hype** (no "blazing/powerful/robust").
- **Emoji: none** by default — only a single leading brand mascot if the
  project has one.
- **Topics: 8–14** across language / own-name / domain / ecosystem / use-case.

Full spec: [`reference/formula.md`](reference/formula.md).

## Install

```bash
git clone https://github.com/<you>/repo-describe.git
cd repo-describe
./install.sh
brew install gh   # if needed
gh auth login     # token needs Administration:write (fine-grained) or repo scope
```

Then run `/repo-describe` inside Claude Code.

> **Token scope:** editing repo metadata needs **Administration: write**
> (fine-grained PAT) or the classic `repo` scope. Contents scope is *not*
> enough — this trips people up.

## Safety

- **Dry run by default.** Nothing writes without `--apply` *and* your explicit
  approval of the review table.
- **Full-replace topics** are shown as a diff before applying.
- Forks and archived repos are skipped unless you opt in.
- Rate-limit aware: writes are serialized with backoff (respects GitHub's
  500-content-writes/hour ceiling).

## Requirements

- [Claude Code](https://claude.com/claude-code)
- [`gh`](https://cli.github.com/) (GitHub CLI), authenticated
- `jq`

## License

MIT © 2026 Matthew Park
# describatory
