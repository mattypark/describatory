# The Description Formula

Reverse-engineered from the "About" metadata of 12 top-starred repos
(react, next.js, vscode, vue, tailwindcss, supabase, ollama, langchain,
deno, svelte, shadcn-ui, transformers). Apply this when drafting any repo's
description and topics.

## Short description

**Length: 30–70 characters.** Never exceed ~120 (GitHub truncates in search,
profile grids, and social cards). Terse wins.

**Pick one of two proven structures:**

1. **Category claim** — `The [X] for [Y].`
   - Leading with "The" claims the category. It is a confidence signal.
   - Examples: "The React Framework", "The agent engineering platform",
     "The library for web and native user interfaces."

2. **Distinctive noun phrase** — `A [distinctive-adjective] [category] for [use-case].`
   - Examples: "A modern runtime for JavaScript and TypeScript",
     "A utility-first CSS framework for rapid UI development."

**Rules:**
- Write a **noun phrase, not a sentence**. No verb-first imperatives.
- Lead with "The" or "A".
- Exactly **one differentiator word** doing real work ("utility-first",
  "progressive", "modern", "zero-config"). It must be true of the code.
- **Ban hype adjectives**: blazing, powerful, amazing, cutting-edge, robust,
  seamless, next-generation, revolutionary.
- A second clause is allowed **only** if it adds a concrete differentiator
  (like Supabase: "…gives you a dedicated Postgres database…").
- End with a period if it reads as a statement; taglines may omit it.
- **Do not parrot the README's first line.** Describe what the code actually
  is and does, especially when the README is empty or generic.

## Emoji

**Default: none.** Only 2 of 12 top repos use one, always as a single leading
brand-mascot glyph (🖖, 🤗). Never decorative 🚀/✨/🔥. Only add one if the
project already has a real visual identity. When unsure, omit.

## Topics / tags

**Set 8–14 topics** (hard cap 20). Cover these buckets:

1. **Language(s)** — javascript, typescript, python, rust, go
2. **The project's own name** — helps it surface in search
3. **Domain / category** — database, cli, editor, css-framework, llm, api
4. **2–3 ecosystem / framework peers** — nextjs, react, postgres, pytorch
5. **1–2 use-case or named-competitor keywords** — firebase, rag, agents

**Format constraints (GitHub rejects violations with 422):**
- Lowercase letters, numbers, hyphens only.
- Must start with a letter or number.
- ≤ 50 chars each, no spaces, no leading/trailing/consecutive hyphens.

## Homepage

**Always set one** if the project has a live site or docs. Point to a
product/docs domain — never the GitHub repo URL itself. If there is no site,
leave it unset (do not invent one).

## Social preview image

**No API exists** to set it. Out of scope for automated push. The tool only
*flags* repos that lack a custom social image so the user can upload one
manually (Settings → General → Social preview). A custom branded card is the
professional signal; GitHub's auto-generated stat-card is the amateur tell.

## Skip rules

By default, do **not** rewrite:
- Forks (unless the user opts in) — the description belongs to upstream.
- Archived repos.
- Repos whose current description already fits the formula well — mark as
  "already good, no change" rather than churning it.
