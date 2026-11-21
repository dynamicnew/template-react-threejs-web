# Agent project template: React + Tailwind v4 + Three.js + Docker (Dual-Platform)

A reusable, dual-platform (**Google Antigravity** and **GitHub Copilot**)
agent scaffolding template for interactive creative and 3D web applications built
with React, Vite, CSS-first Tailwind CSS v4, Three.js WebGL viewports, optional
schema-validated data catalogs and serverless API relays, and Docker-only build,
Playwright E2E, and CI verification. Contains no application code, project lore,
machine-specific paths, or secrets.

## How loading works

Files on disk cost zero tokens until loaded. Both Antigravity and GitHub Copilot
automatically discover root `AGENTS.md` and portable skills under
`.agents/skills/` (the open Agent Skills standard). Keep only `AGENTS.md` at the
root (no `GEMINI.md`). If you use GitHub Copilot Code Review or Visual Studio,
add a one-line `.github/copilot-instructions.md` containing:
`Follow [AGENTS.md](../AGENTS.md).` Do not use `@path` or `@[label](path)`
includes in either file.

| Layer | Loaded when | Platform | Cost |
|---|---|---|---|
| `AGENTS.md` | Every session | Both | Small and fixed (the only always-on file, <= ~70 lines) |
| `.agents/rules/*.md` | `trigger: model_decision` | Antigravity | Only when relevant |
| `.github/instructions/*.instructions.md` | Matching file (`applyTo`) | GitHub Copilot | Only when matching files are touched |
| `.agents/skills/*` | Names/descriptions at startup; `SKILL.md` on use | Both (portable) | Progressive disclosure |
| `.agents/agents/*` / `.github/agents/*` | When invoked / delegated | Platform-native | Only when used |
| `docs/ai/*` & `docs/brand/*` | When `AGENTS.md` or rules point to them | Both | Only on demand, by heading |
| `docs/ai/read-lists/*` | When a subagent starts | Both | One small file per subagent role |

> **VS Code note:** Keep `.agents/skills` enabled in `chat.agentSkillsLocations`
> so GitHub Copilot loads the single canonical skill tree in `.agents/skills/`
> without duplicating skills into `.github/skills/`.

## Adopt it

1. Click **Use this template** on GitHub (or copy the contents of `react-threejs-web/` into your repository root).
2. Fill in `Project essentials` in [AGENTS.md](AGENTS.md) with your routes,
   build scripts, and Docker Compose service names (keep `AGENTS.md` under ~70 lines).
3. Fill in [docs/brand/identity.md](docs/brand/identity.md) with your brand
   naming rules, semantic color scales, theme modes, and preserved features.
4. Track unresolved questions and open approvals in
   [docs/ai/concerns.md](docs/ai/concerns.md) instead of scattering them across
   multiple docs or production UI copy.
5. Update [docs/ai/cost.md](docs/ai/cost.md) with your Antigravity and/or GitHub
   Copilot plan limits and preferred models.
6. If this repository supports ClarifyDoc, run `setup-clarifydoc` during
   adoption or initial setup to generate the ClarifyDoc rule, skills,
   `.gitignore` entry, and MCP guidance on demand (otherwise create none).
7. Delete anything you do not use.
8. Run `pwsh -NoProfile -File scripts/check-context-size.ps1 -FailOnWarning`
   to verify always-on budgets, Antigravity rule caps, and skill deduplication.

## Curated skills included

Stored once in `.agents/skills/` for both platforms:

- **Core workflow:** `coordinate-task` (Antigravity main-agent coordination),
  `project-remember`, `systematic-debugging` (browser, WebGL/Three.js, CSS
  themes/a11y, catalog asset generation, and API relay),
  `verification-before-completion` (evidence matrix separating Docker build,
  unit, asset-hash, component-fixture, E2E, and real-hardware/live-relay checks).
- **On-demand generators:** `generate-handoff-canvas` (recreates a read-only
  Copilot `.github/extensions/<id>/` canvas or Antigravity MCP App side-pane
  panel), `setup-clarifydoc` (detects ClarifyDoc support at template
  adoption/init and scaffolds only the needed ClarifyDoc config, rules, and
  workflow skills).

## What is deliberately omitted

- **No application code, brand lore, secrets, or machine-local paths.** MCP
  configs live as empty `.example` templates (`.agents/mcp_config.json.example`
  and `.mcp.json.example`); note that `.mcp.json` and Antigravity's active
  `.agents/mcp_config.json` use `"mcpServers"`, while VS Code's
  `.vscode/mcp.json` expects `"servers"`. Never commit webhook URLs, tokens, or
  local paths.
- **No enabled hooks.** See `.agents/hooks/README.md` and
  `.github/hooks/README.md`.
- **No heavy vendor skill asset bundles.** External UI/React/Playwright/design
  skills (with fonts or component archives) are intentionally excluded so the
  template stays light; install only vetted skills your team needs.
- **No prebuilt canvas extension or ClarifyDoc skill trees.** Use
  `generate-handoff-canvas` and `setup-clarifydoc` to scaffold those assets only
  in repositories that actually need them.

## Layout

```text
AGENTS.md                                  always-loaded dual-platform router (<= ~70 lines)
.agents/
  rules/                                   8 Antigravity conditional rules (model_decision)
  agents/                                  implementer, reviewer, handoff (explore uses built-in research)
  skills/                                  6 shared portable skills (core + canvas & ClarifyDoc generators)
  hooks/README.md                          hook policy (none enabled)
  mcp_config.json.example                  empty MCP server list (Antigravity format)
.github/
  instructions/                            8 Copilot path-scoped instructions (applyTo)
  agents/                                  coordinator, explorer, implementer, reviewer, handoff
  hooks/README.md                          hook policy (none enabled)
  pull_request_template.md                 PR verification & handoff checklist
docs/
  ai/                                      handoff.md, handoff-history/, todo.md, decisions.md, concerns.md, memory.md, cost.md, read-lists/
  brand/identity.md                        brand identity, theme tokens & vision template
  codebase/README.md                       index for optional on-demand architecture maps
scripts/check-context-size.ps1             dual-platform context-budget & hygiene check
.mcp.json.example                          empty MCP server list (Copilot CLI / portable format)
.gitignore  .gitattributes                 dependency/secret hygiene & consistent LF endings
```
