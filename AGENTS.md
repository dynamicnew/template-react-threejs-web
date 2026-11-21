# Project guidance

The only file loaded every session; read everything else on demand. Keep this
file under 70 lines.

## Project essentials (fill in)

- **Stack & layout:** <!-- React + Vite + Tailwind CSS v4 (`src/styles/main.css`) + Three.js (`src/components/`), routes (`src/pages/`), optional `api/` & `src/catalog/`, `tests/`, `docker/` -->
- **Commands:** <!-- dev: `npm run dev` | build: `npm run build` | Docker tests: `docker compose build tools ui-tests && docker compose run --rm --no-deps tools && docker compose run --rm --no-deps ui-tests` -->
- **Do not edit:** <!-- generated outputs directly (edit generators instead), `node_modules/`, or unrelated repos in a multi-root workspace -->

## When to read what

- Small task (one file, question, quick fix): read nothing extra.
- Substantial work: consult `find-skills` (if installed) once before planning.
- Multi-file or cross-session work: read `#current-handoff` in
  [docs/ai/handoff.md](docs/ai/handoff.md), [docs/ai/todo.md](docs/ai/todo.md),
  and [docs/ai/concerns.md](docs/ai/concerns.md), then verify against Git/source.
- Brand, lore, theme or copy work: read [docs/brand/identity.md](docs/brand/identity.md).
- Large docs: locate the relevant heading and read only that section.
- Procedures (coordination, debugging, verification, memory, canvas, or
  `setup-clarifydoc` on adoption/init): load from `.agents/skills/`.
- Explicit user direction overrides standing rules and can revise canon; update
  the governing source of truth and tests together.

## Rules

- **Truthful.** Run checks before claiming success. Report failures, flakes,
  skips and unknowns plainly. Keep internal status and open decisions out of
  production UI copy (use `docs/ai/concerns.md`). Never record secrets or PII.
- **Docker-only tests.** Run all automated and subagent tests in Docker; never
  fall back to host-native tests. Rebuild images after edits; never commit
  `node_modules/`.
- **Preserve vision & clean.** Brand canon, creative work and interactive
  features are deliberate: prefer adding/refining over removing. Remove own
  scratch files and dead code; do not refactor untouched files.
- **Branches & commits.** Develop on `feature/<topic>`, merge into `dev` (then
  delete the merged branch with `git branch -d`), and stop at `dev`; only PR
  `dev` into `main` when asked to release. Commit verified batches (main agent /
  coordinator only; subagents never commit). Never push/rewrite unless asked.
- **Ask first.** Stop and ask before changing IDE, user, account or billing
  settings; accessing signed-in accounts; deploying; revising canon/scope; or
  destructive actions.
- **Cost & communication.** Read [docs/ai/cost.md](docs/ai/cost.md) for model
  tiers and delegation. Be terse; no progress narration; end with one short
  report (files changed, exact checks, unverified).
- **Memory.** Record verified lessons with `project-remember`. Keep settled
  decisions in `docs/ai/decisions.md` and open questions in `docs/ai/concerns.md`.

## Subagents

Give each subagent only its bounded task, exclusive file ownership and read-list
from [docs/ai/read-lists/](docs/ai/read-lists/) (`research`/`Explorer` ->
`explore.md`, `implementer`/`Implementer` -> `implement.md`,
`reviewer`/`Reviewer` -> `review.md`). `handoff`/`Project Handoff` reads
`docs/ai/handoff.md`, `docs/ai/todo.md`, and `docs/ai/concerns.md` directly.

## Map

| Need | Where |
|---|---|
| State, TODOs, decisions, concerns, lessons, cost | [docs/ai/](docs/ai/) (`handoff.md`, `todo.md`, `decisions.md`, `concerns.md`, `memory.md`, `cost.md`) |
| Brand identity & optional codebase maps | [docs/brand/identity.md](docs/brand/identity.md), [docs/codebase/README.md](docs/codebase/README.md) |
| Conditional rules (Antigravity / Copilot) | [.agents/rules/](.agents/rules/), [.github/instructions/](.github/instructions/) |
| Subagent roles (Antigravity / Copilot) | [.agents/agents/](.agents/agents/), [.github/agents/](.github/agents/) |
| Shared skills (Antigravity + Copilot) | [.agents/skills/](.agents/skills/) |
