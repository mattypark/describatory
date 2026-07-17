# describatory

**Learn your whole GitHub, then rewrite every repo's description in one consistent voice — automatically.**

Your READMEs get all the love. The one-line **description** in each repo's
"About" sidebar — the line that shows in search, your profile grid, and social
cards — is usually empty, stale, or generic. And your **profile** (bio +
profile README) is often an afterthought.

`describatory` fixes all of it in one pass. It reads your actual code, learns
who you are as a developer, and writes professional descriptions + topics for
every repo, plus your bio and profile README — in one voice, reviewed before
anything is pushed.

It runs as a Claude Code command (`/repo-describe`), and the underlying scripts
work in Cursor or any agent too.

---

## How it works

describatory is a pipeline. Each stage is a small shell script; **Claude writes
the copy** using a written formula, so there's no external API key.

```
1. LEARN     Read all your repos + profile → build a "developer identity"
             (what you build, your stack, signal projects, your voice).

2. GATHER    For each repo: pull its README + languages (the real code signal).

3. DRAFT     Claude writes a 30–70 char description + 8–14 topics per repo,
             in your voice, positioned against your whole portfolio.

4. REVIEW    You see a current → proposed table. Approve, edit, or cancel.
             Nothing is written before this.

5. APPLY     Serialized, rate-limit-aware writes via the GitHub API.

6. REPORT    What changed, what didn't, and which repos still need a social
             image (GitHub has no API for that — you upload those manually).
```

Three modes share this pipeline:

| Command | What it does |
|---------|--------------|
| `/repo-describe` | Learn the account, then describe **every repo** (About + topics). |
| `/repo-describe --profile` | Write your **bio** + **profile README** (`USERNAME/USERNAME`). |
| `/repo-describe owner/repo --media` | Enrich **one repo's README** with banner, screenshots, badges, video. |

### The account-learning step

describatory never describes repos in isolation. Before writing, it reads *all*
your repos and profile and synthesizes a **developer identity** — the recurring
themes, your dominant stack, your best projects, your tone. It shows you that
identity and lets you correct it. Then every description comes out consistent
and sensibly positioned (it won't call three of your projects "the" platform for
the same thing).

### The description formula (why the output looks professional)

Reverse-engineered from 12 top-starred repos (react, next.js, supabase, …):

- **30–70 characters.** GitHub truncates longer.
- **"The X for Y."** (category claim) or **"A [adjective] [category] for
  [use-case]."** Never verb-first.
- One real differentiator word; **zero hype** ("blazing/powerful/robust" banned).
- **Emoji: none** by default — only a single leading brand mascot if the project
  has one.
- **Topics: 8–14** spanning language / own-name / domain / ecosystem / use-case.

Full spec: [`reference/formula.md`](reference/formula.md).

---

## Install (one command)

```bash
git clone https://github.com/<you>/describatory.git
cd describatory
./install.sh
```

`install.sh` does everything: installs `gh` + `jq` if missing, logs you into
GitHub (one browser click), and installs the command. Then open Claude Code and
run `/repo-describe`.

> **Auth is one browser click.** `gh auth login`'s default scopes cover the
> `Administration: write` needed to edit repo metadata. A token works too but is
> *more* steps — the browser flow is the easy path. This is the one
> unavoidable step: GitHub won't let anything edit your repos without it.

---

## How to run it

**Describe all your repos** (dry run — shows the review table, pushes nothing):
```
/repo-describe
```

**Actually apply** after reviewing:
```
/repo-describe --apply
```

**One repo only:**
```
/repo-describe owner/repo
```

**Write your bio + profile README:**
```
/repo-describe --profile
```

**Add media to a repo's README:**
```
/repo-describe owner/repo --media
```

Flags: `--public-only`, `--include-forks`, `--include-archived`.

---

## Media mode — and how images work

The most professional-looking repos are full of banners, screenshots, badges,
and demo videos. `--media` adds that to one repo's README.

**It asks you about images first.** Before doing anything, the skill asks what
you already have:

> Do you have images/videos for this repo?
> 1. **I have image files** — screenshots, logo, demo GIF.
> 2. **I only have links** — hosted image URLs, a YouTube/Loom link, a live site.
> 3. **Nothing** — generate a banner + capture screenshots for me.

Then it sorts placement for you:

- **Files** → it confirms each file's purpose, moves it into `assets/`, and wires
  it with real alt text. 3+ images is ideal; one good hero is enough; it's
  optional.
- **Links** → hosted image URLs get used directly (or downloaded into `assets/`
  for permanence); a YouTube/Loom/site link becomes a clickable video thumbnail
  or a live-site screenshot.
- **Nothing** → it **captures** screenshots of your live site (if the repo has
  one) and **generates** a 1280×640 banner via fal.ai — which also doubles as
  your GitHub social-preview image.

It wires everything into the README (banner, badge row, hero, feature grid,
video, certificates) with correct sizing and alt text, shows you a diff, and
**hands the commit to you** — it never auto-commits README or binary assets.
Full playbook: [`reference/media.md`](reference/media.md).

---

## Profile mode

`/repo-describe --profile` writes your two account-level surfaces:

- **Bio** — the ≤160-char line under your name (concrete, no "passionate
  developer 🚀" fluff), written via the GitHub API.
- **Profile README** — the `USERNAME/USERNAME` repo shown at the top of your
  profile: a scannable overview with a featured-projects table built from your
  best repos (reusing the same descriptions, so profile and repos agree). If
  that repo doesn't exist, it offers to create it.

Both are drafted, shown to you, and only written after you approve.
Playbook: [`reference/profile.md`](reference/profile.md).

---

## Safety

- **Dry run by default.** Nothing writes without `--apply` *and* your approval
  of the review table.
- **Topics are shown as a diff** before applying (they're a full replace).
- **README media and the profile README are never auto-committed** — you run the
  commit.
- **Forks and archived repos are skipped** unless you opt in.
- **Rate-limit aware:** writes are serialized with backoff (respects GitHub's
  500-content-writes/hour ceiling).

---

## Using it without Claude Code

The tool is portable shell scripts + a written formula, so **Cursor, other
agents, or manual use all work**. See
[`docs/USING-WITH-OTHER-TOOLS.md`](docs/USING-WITH-OTHER-TOOLS.md).

---

## Requirements

- [Claude Code](https://claude.com/claude-code) (or any agent — see above)
- [`gh`](https://cli.github.com/) (GitHub CLI), authenticated
- `jq`

`install.sh` sets up `gh` and `jq` for you.

---

## Repo layout

```
commands/repo-describe.md        the slash command (the orchestration brain)
reference/formula.md             repo-description formula
reference/profile.md             account identity, bio, profile README
reference/media.md               README media + image-intake playbook
scripts/list-repos.sh            enumerate your repos
scripts/fetch-repo.sh            one repo's README + languages
scripts/fetch-user.sh            account signal + profile-repo detection
scripts/apply.sh                 write description / homepage / topics
scripts/apply-profile.sh         write bio + profile README
scripts/media-scaffold.sh        set up assets/ + badge row
install.sh                       one-command setup
```

## License

MIT © 2026 Matthew Park
