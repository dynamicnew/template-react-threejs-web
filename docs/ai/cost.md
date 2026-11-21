# Cost guidance

Read this when choosing a model, starting a long session, or delegating work.
Quality, accessibility, and verification come first; never weaken them to save
quota or credits.

## Your numbers (fill in or adjust)

| Item | Antigravity | GitHub Copilot |
|---|---|---|
| Monthly budget / plan | *(fill in; rolling quota pools tracked per family)* | *(fill in — USD or monthly AI credits)* |
| Daily review point (advisory) | Warn at `<= 25%` pool remaining | *(fill in — e.g., `<= 25%` or `$X`/day)* |
| Per-session limit | Check in before spending `> 20%` of a pool | *(fill in — e.g., `--max-ai-credits <n>`)* |
| Light-tier model | `Gemini 3.8 Flash (Low/Medium)`; subagents: `flash_lite` / `flash` | `gpt-6-luna` (alt: `mai-code-2-flash`) |
| Standard-tier model | `Gemini 3.8 Flash (High)` or `Claude Sonnet 5.5 (Medium)`; subagents: `inherit` | `gpt-6.1-terra` |
| Strong-tier model (needs a reason) | `Gemini 4 Neon (High)` or `Claude Sonnet 5.5 (High)`; subagents: `pro` | `gpt-6.1-sol` |
| Needs user's explicit OK | `Claude Opus 5.5 (Medium/High)` and `XHigh` reasoning tiers | `claude-opus-5.5` |

Re-check model availability and pricing in your active model picker; plans,
surfaces, and context-threshold pricing tiers change over time.

## Match the model to the work

| Work | Tier |
|---|---|
| Search, listing, reading files, summarizing, formatting | Light (`flash_lite` / `flash` / `Explorer`) |
| Everyday coding with a clear plan, routine edits, running Docker tests, writing docs | Standard (`inherit` / `Implementer`) |
| Architecture, WebGL/Three.js debugging, accessibility review, ambiguous diffs | Strong (`pro` / `Reviewer`) |

Plan with a strong model, then implement with a standard one.

## Keep prompt-prefix caching warm

Prompt caching reuses the unchanged prefix of your conversation; switching
models, reasoning effort, or enabled tools/MCP servers mid-session invalidates
the cache and forces full context reprocessing.

- Pick one model per session and keep it.
- Start a fresh session for each unrelated task and after a long break.
- Resume from `docs/ai/handoff.md` rather than a stale long session.
- Compact (`/compact`) only when a long session will keep going, at a milestone.

## Keep the context small

- Read large files by heading, not in full. Attach only needed files.
- Keep `AGENTS.md` under ~70 lines; put stack rules in `.agents/rules/*.md`
  (`trigger: model_decision`) and `.github/instructions/*.instructions.md`
  (`applyTo`).
- Give subagents one read-list from `docs/ai/read-lists/`, not the handoff.
- Delegate only when bounded work justifies overhead; run 0–3 concurrent
  subagents and keep exploration on the light tier.
- Enable only the plugins, tools, and MCP servers the task needs.

## Guardrails

- Check remaining quota/credits at the start of a long day; warn at the review
  point. In Copilot CLI, consider `--max-ai-credits <n>` or `/limits set`.
- Ask before switching to higher-cost models, enabling new MCP servers,
  changing plans/budgets/account settings, or running quota-heavy workflows.
- Treat UI estimates as approximate; the account billing page is authoritative.
  Keep raw usage exports (`ai-credits*.csv`) out of Git, separate included
  allowance from overage, and never infer per-repo/per-task spend from
  aggregate totals unless the source carries that attribution.
