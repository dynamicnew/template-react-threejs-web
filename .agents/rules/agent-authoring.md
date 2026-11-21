---
trigger: model_decision
description: Guidance for authoring or modifying AGENTS.md, rules, instructions, agents, skills, and hook docs under .agents/ or .github/.
---

- Define clearly when the guidance applies, its inputs, expected outcome,
  safety boundaries, and how failures or missing context are reported.
- Reuse canonical repository docs and tools instead of duplicating workflows.
  Keep model choices, external services, and automatic side effects optional
  unless explicitly required.
- Keep shared skills in `.agents/skills/<name>/SKILL.md` (single portable
  source for Antigravity and GitHub Copilot) with frontmatter `name` matching
  the folder name; do not duplicate them under `.github/skills/`.
- Use valid platform frontmatter (`trigger` for `.agents/rules/`, `applyTo` for
  `.github/instructions/`), working relative links, and no literal secrets or
  machine-specific absolute paths.
- Keep root `AGENTS.md` under ~70 lines; run
  `pwsh -NoProfile -File scripts/check-context-size.ps1` after edits.
