# The Account & Profile Playbook

This is what makes describatory understand your GitHub as a whole *person*, not
a pile of unrelated repos. It covers three things:

1. **Learn** — synthesize a developer identity from all repos + profile.
2. **Bio** — the 160-char line under your name.
3. **Profile README** — the `USERNAME/USERNAME` repo shown on your profile.

The learned identity also feeds every per-repo description so they share one
voice and position against each other.

## 1. Learn the account (identity synthesis)

Inputs: `fetch-user.sh` (profile fields + existing profile README) and
`list-repos.sh` (every repo's name, description, primary language, topics,
stars, pushed_at).

Produce a short **developer identity** (internal, 3–5 sentences) capturing:
- **What they build** — the recurring domains (web apps, dev tools, ML, games).
  Cluster the repos; name the 2–4 themes that actually repeat.
- **Stack** — dominant languages/frameworks by frequency across repos (derive
  from the `language` field and topics; don't over-weight one big repo).
- **Signal projects** — the few highest-star / most-recently-active repos that
  best represent them.
- **Level & voice** — infer from README quality and project ambition; match a
  professional but genuine tone (not "passionate 10x rockstar" fluff).

Show this identity to the user before writing anything and let them correct it.
Everything downstream (bio, profile README, per-repo descriptions) uses it.

## 2. Bio (PATCH /user)

The line under your name. ≤ **160 chars**. Same discipline as repo descriptions:

- State **what you build and for whom**, concretely. One specific domain beats
  five vague adjectives.
- Good: "I build AI dev tools and web apps. Creator, 30M+ views. Working on
  developer tooling + creator software."
- Bad: "Passionate developer | Coding enthusiast | Always learning 🚀"
- **Ban**: "passionate", "enthusiast", "ninja/rockstar/guru", "10x", emoji piles.
- One link (blog/site) belongs in the profile's website field, not crammed in
  the bio.

## 3. Profile README (USERNAME/USERNAME repo)

The big one — a detailed, scannable overview of the person and their work.
GitHub renders `README.md` from the `USERNAME/USERNAME` repo at the top of the
profile page. If that repo doesn't exist, describatory offers to create it.

### Structure (top → bottom)

1. **Header** — name + one-line identity (the bio, expanded). Optional centered
   banner (generate via the media playbook, 1280×640).
2. **What I build** — 2–4 sentences from the learned identity. Concrete.
3. **Featured projects** — a curated table of the 3–6 signal repos, each with
   its (newly written) description and a link. This is the heart of it.
4. **Tech** — the real dominant stack, as a short list or badge row. Only what
   actually shows up across repos — no aspirational tech theatre.
5. **Stats** (optional) — GitHub stats card / top-languages card if wanted.
6. **Connect** — real links only (site, X, LinkedIn, email). No dead icons.

### Markdown patterns

**Header:**
```markdown
# Hi, I'm <Name> 👋
### <One-line identity — what you build, for whom>
```

**Featured projects table:**
```markdown
## Featured projects

| Project | What it is |
|---------|-----------|
| **[describatory](https://github.com/USER/describatory)** | The tool that rewrites your GitHub's About sections in bulk. |
| **[project-two](https://github.com/USER/project-two)** | A zero-config CRM for solo founders. |
```

**Tech (badge row — real stack only):**
```markdown
## Tech
`TypeScript` · `Next.js` · `Python` · `Supabase` · `Swift`
```

**Stats cards (optional, third-party service):**
```markdown
![Stats](https://github-readme-stats.vercel.app/api?username=USER&show_icons=true)
![Top langs](https://github-readme-stats.vercel.app/api/top-langs/?username=USER&layout=compact)
```

**Connect:**
```markdown
## Connect
[Website](https://...) · [X](https://x.com/...) · [LinkedIn](https://...)
```

### Rules

- **Pull descriptions from the per-repo pass**, so the profile and each repo's
  About say the same thing. One source of truth.
- Feature real, active, representative repos — not every repo, not forks.
- No fabricated stats, awards, or tech. If it's not in the repos, it's not on
  the profile.
- Keep it scannable: headers, a table, short lines. Nobody reads a wall.
- Emoji: a single 👋 in the header is fine; otherwise sparse.

## Safety

- Writing the bio (PATCH /user) and profile README (commit to USERNAME/USERNAME)
  are real writes. Draft → show the user → get explicit approval → only then
  apply. Never write the profile without a yes.
- Creating the USERNAME/USERNAME repo is a public action — confirm before
  creating it.
