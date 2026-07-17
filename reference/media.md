# The README Media Playbook

The repos that "look the most professional" all share a media anatomy: a
centered banner, a badge row, a hero screenshot or demo GIF, and a small grid
of feature shots — sometimes a video. This playbook defines what media a great
README carries, how to acquire it, and the exact markdown to place it.

Applies to the README **file** (this is heavier than the About sidebar — it
means editing README.md and committing assets, so it runs as an opt-in
`--media` mode and never auto-commits).

## Media anatomy of a top README (top → bottom)

1. **Banner / logo** — centered, full-width. Doubles as brand identity.
2. **Tagline** — the one-line description (reuse the About description).
3. **Badge row** — license, stars, build, version. Deterministic, no files.
4. **Nav links** — Docs · Demo · Changelog · Discord (only real ones).
5. **Hero** — ONE of: product screenshot, or an autoplay demo **GIF**.
6. **Feature grid** — 2–3 screenshots, often in a 2-col table.
7. **Video** (optional) — thumbnail image linking to YouTube, or an
   uploaded `.mp4` (GitHub renders a player for drag-dropped mp4).
8. **Certificates / awards** (optional) — a centered row of small badges.

Not every repo needs all of it. A CLI needs a banner + one terminal GIF. A web
app needs a banner + 2–3 UI screenshots. Match media to what the project is.

## Image intake — ASK FIRST (do this before anything else)

Before capturing, generating, or writing any markdown, the skill must **ask the
user what media they already have**. Do not assume. Ask a clear, structured
question:

> Do you have images/videos for this repo?
> 1. **I have image files** — I'll drop them (screenshots, logo, demo GIF).
> 2. **I only have links** — hosted image URLs, a YouTube/Loom link, a live site.
> 3. **Nothing** — generate a banner + capture screenshots for me.
>
> (3+ images make a README look best, but it's optional — one good hero is
> enough. Tell me what you've got.)

Then comprehend the answer and route each item:

- **Files provided** → confirm each file's purpose ("this one's the hero? this
  one's a feature shot?"), move it into `assets/` with a clear name, wire it
  with real alt text. If they gave more than the layout needs, pick the
  strongest and say which you dropped.
- **Links only** → two sub-cases:
  - *Hosted image URL* (ends in .png/.jpg/.gif or a CDN) → you may reference it
    directly as the `src`, OR offer to download it into `assets/` so it survives
    if the host dies (recommend downloading for anything load-bearing).
  - *Page/video link* (YouTube, Loom, a live site) → use the video-thumbnail
    pattern (thumbnail image linking out), or screenshot the live site.
- **Nothing** → fall back to CAPTURE (screenshot the site) + GENERATE (banner),
  per the three methods below.

Always tell the user where each image ended up (`assets/…`) and how it's wired,
so the layout is never a surprise. If they're unsure where something goes, you
decide using the anatomy above and explain the choice.

## The three ways to get each image

Decide per slot. Prefer real over generated for anything showing the product.

### 1. CAPTURE (best for screenshots) — automated
If the repo has a live `homepage` site, screenshot it with the Claude-in-Chrome
browser tools at real breakpoints:
- Desktop hero: **1440** wide.
- Mobile: **768** wide.
Save into `assets/screenshots/`. These are authentic product shots — always
better than a mockup. Use for the hero and feature grid.

### 2. GENERATE (best for banner/atmosphere) — automated via fal.ai
Use the `mcp__fal-ai__generate` tool for slots where no real artifact exists:
- **Banner** at **1280×640** (this size also works as the GitHub social
  preview image — generate once, use twice).
- Abstract/atmospheric backgrounds behind a wordmark.
Never generate fake "screenshots" of UI that doesn't exist — that's
misleading. Generation is for branding, not product proof.

### 3. REQUEST (for demos, certs, anything real you can't capture)
When a slot needs something only the user has — a demo recording, a
certificate, a logo, a specific screenshot of a non-web app — the skill must
STOP and ask with an exact checklist, e.g.:

> I need 3 files to finish this README. Drop them anywhere and tell me the paths:
> 1. **Demo GIF/MP4** — a 5–15s screen recording of the main flow (for the hero).
> 2. **Screenshot** — the dashboard/main screen (for the feature grid).
> 3. **Certificate/award image** (optional) — any badge to show off.
>
> No banner from you needed — I'll generate a 1280×640 one.

Then place the provided files into `assets/` and wire them in. Confirm each
file's purpose before placing so nothing lands in the wrong slot.

## File layout

```
assets/
  banner.png            1280×640 (also usable as social preview)
  screenshots/
    hero-1440.png
    feature-1.png
    feature-2.png
  demo.gif              user-provided recording
  certs/
    cert-1.png
```

Optimize before committing: PNG for UI, GIF for short demos (keep < 5 MB so it
autoplays smoothly), MP4 for anything longer. Always set explicit widths.

## Standard header block (REQUIRED — every README opens with this)

Every README this tool writes MUST open with this exact centered block: title →
rule → tagline → badge row → punchline → rule. It's the house style — clean,
centered, professional. Do not deviate from the structure; only fill in the
content.

```html
<div align="center">

# ProjectName

<img src="https://img.shields.io/badge/--000000?style=flat-square" width="100%" height="1" alt="">

### <one-line hook — punchy, specific, lowercase is fine>

<p>
  <img src="https://img.shields.io/badge/CI-passing-brightgreen?style=flat&logo=github" alt="CI">
  <img src="https://img.shields.io/badge/License-MIT-yellow?style=flat" alt="License">
  <img src="https://img.shields.io/badge/node-%3E%3D20-brightgreen?style=flat" alt="node">
  <img src="https://img.shields.io/badge/TypeScript-strict-blue?style=flat" alt="TypeScript">
  <img src="https://img.shields.io/badge/PRs-welcome-ff69b4?style=flat" alt="PRs welcome">
</p>

**<short punchline / sub-tagline — a little personality is good>**

</div>

---
```

Rules for the header:
- **Title**: the project name as an `<h1>`, centered.
- **Hook** (the `###` line): the strongest one-sentence value prop. Punchy and
  specific — "your AI agent reads your ENTIRE repo to fix one bug. i fixed it."
  beats "a tool for context optimization." Reuse/expand the About description.
- **Badges**: only include badges that are TRUE. Swap per project:
  - `License-<MIT|Apache--2.0|...>` — match the actual LICENSE.
  - `node-%3E%3D20` → the real runtime (`python-3.12`, `swift-5.9`, etc.).
  - `TypeScript-strict` only if `tsconfig` has `strict: true`; drop otherwise.
  - `CI-passing` only if a workflow exists — better: use the live badge
    `github/actions/workflow/status/OWNER/REPO/ci.yml`. No CI → drop it.
  - `PRs-welcome` is fine on any open-source repo.
  - Keep 3–5 badges. Dead/false badges look worse than none.
- **Punchline** (the bold line): one more line with personality — the "lol"
  energy in the reference is intentional; keep it human, not corporate.
- Close with `</div>` then a `---` rule before the body ("## what is this").

Below this header comes the banner/screenshots/etc. from the anatomy above.

## Optional footer block (license + contact)

Close long READMEs with a matching centered footer:

```html
---

<div align="center">

**<ProjectName>** · MIT © <year> <Name>

[Website](https://...) · [X](https://x.com/...) · [GitHub](https://github.com/USER)

</div>
```
Only include links that resolve. Match the LICENSE line to the actual license.

## Markdown patterns (copy these exactly)

**Centered banner:**
```html
<p align="center">
  <img src="assets/banner.png" alt="ProjectName — the X for Y" width="820">
</p>
```

**Badge row** (shields.io, deterministic — fill OWNER/REPO):
```markdown
<p align="center">
  <img src="https://img.shields.io/github/license/OWNER/REPO" alt="License">
  <img src="https://img.shields.io/github/stars/OWNER/REPO" alt="Stars">
  <img src="https://img.shields.io/github/last-commit/OWNER/REPO" alt="Last commit">
  <img src="https://img.shields.io/github/actions/workflow/status/OWNER/REPO/ci.yml" alt="Build">
</p>
```
Add `https://img.shields.io/npm/v/PKG` for npm packages, `.../pypi/v/PKG` for
PyPI. Only include a build badge if a workflow actually exists.

**Nav links:**
```markdown
<p align="center">
  <a href="HOMEPAGE">Docs</a> ·
  <a href="DEMO_URL">Live demo</a> ·
  <a href="CHANGELOG.md">Changelog</a>
</p>
```

**Hero screenshot / demo GIF:**
```html
<p align="center">
  <img src="assets/demo.gif" alt="ProjectName in action: <describe the flow>" width="860">
</p>
```

**Feature grid (2-col table):**
```markdown
| | |
|---|---|
| ![Alt describing shot 1](assets/screenshots/feature-1.png) | ![Alt describing shot 2](assets/screenshots/feature-2.png) |
```

**Video thumbnail → link:**
```markdown
<p align="center">
  <a href="https://youtu.be/VIDEO_ID">
    <img src="assets/screenshots/hero-1440.png" alt="Watch the demo" width="820">
  </a>
</p>
```

**Certificates / awards row:**
```html
<p align="center">
  <img src="assets/certs/cert-1.png" alt="<award name>" height="110">
  <img src="assets/certs/cert-2.png" alt="<award name>" height="110">
</p>
```

## Accessibility (required)

Every image needs real alt text describing what it shows — not "image" or the
filename. Screen readers and search both use it. Decorative-only banners may
use `alt=""` but a banner with the project name should describe it.

## Skip / safety rules

- **Never auto-commit.** Scaffold assets + edit README locally, then hand the
  commit to the user (their git rule).
- Don't generate fake product screenshots.
- Don't add badges for CI/npm/PyPI that don't exist — dead badges look worse
  than none.
- Only add nav links to URLs that resolve.
- If a repo already has good media, leave it; suggest additions, don't replace.
