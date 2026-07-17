# Using describatory with Cursor, other agents, or by hand

The Claude Code `/repo-describe` command is the smoothest way to run this, but
the tool is built as **portable shell scripts + a written formula**, so any AI
agent (Cursor, Windsurf, Copilot Chat, ChatGPT, Claude in a browser) — or you,
manually — can drive it. Nothing is Claude-Code-specific except the convenience
wrapper.

The scripts do the GitHub plumbing. Your AI (or you) writes the copy using the
formula. Then a script applies it.

## One-time setup

```bash
git clone https://github.com/<you>/describatory.git
cd describatory
./install.sh          # installs gh + jq, logs you in, installs scripts
```

After this the scripts live at `~/.claude/repo-describe/scripts/` and the
formula at `~/.claude/repo-describe/reference/`.

## The workflow (any agent)

### 1. List your repos
```bash
~/.claude/repo-describe/scripts/list-repos.sh
```
Outputs one JSON object per repo (name, current description, topics, homepage,
language, stars).

### 2. Read one repo's code signal
```bash
~/.claude/repo-describe/scripts/fetch-repo.sh owner/repo
```
Outputs its README (raw), languages, and whether it has a social image.

### 3. Draft the copy with your AI
Paste two things into Cursor / your agent:
- The contents of `~/.claude/repo-describe/reference/formula.md`
- The output of steps 1–2

Ask it: *"Using this formula, write a 30–70 char description and 8–14 topics
for this repo."* The formula bans hype words, sets length, and defines the
"The X for Y" structure — so any decent model produces on-brand output.

### 4. Apply it
```bash
~/.claude/repo-describe/scripts/apply.sh owner/repo \
  --description "The X for Y." \
  --topics "a,b,c" \
  --apply
```
Leave off `--apply` to preview (dry run). Leave off `--topics` to keep topics.

### 5. README media (optional)
```bash
~/.claude/repo-describe/scripts/media-scaffold.sh --dir /path/to/repo --slug owner/repo
```
Then follow `~/.claude/repo-describe/reference/media.md` to place a banner,
screenshots, badges, and video. Your agent can generate a banner or you can
drop your own images into `assets/`.

## Cursor tip: make it a rule

Drop `reference/formula.md` into your project's `.cursor/rules/` (or paste it
into a custom mode) so Cursor always writes descriptions on-brand without you
re-pasting the formula each time.

## Why there's no zero-auth version

Editing your repos requires GitHub to know it's you. `gh auth login` (one
browser click) is the simplest auth GitHub offers — a personal access token is
more steps, not fewer. Every path through this tool needs it once.
