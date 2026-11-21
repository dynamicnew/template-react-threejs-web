# Codebase maps (optional, read on demand)

Add concise, evidence-backed reference maps here only as the project grows, so
agents can inspect a single concern without reading large source trees or
inflating always-on `AGENTS.md`:

- `ARCHITECTURE.md` — SPA shell, lazy routes, Three.js `stateRef` bridge, and serverless API flow.
- `STACK.md` — Node/Vite/React/Tailwind v4/Three.js manifests, `.nvmrc`, and Docker commands.
- `STRUCTURE.md` — entry points and folder navigation (navigation only, not duplicate rules).
- `CONVENTIONS.md` — naming, ESM relative imports, error/relay status codes, and test layout.
- `TESTING.md` — Docker test jobs, Playwright desktop/mobile E2E matrix, and asset hash checks.
- `INTEGRATIONS.md` — browser APIs, optional webhook relay, and secrets boundaries.

Keep active open decisions, questions, and flakes in
[docs/ai/concerns.md](../ai/concerns.md) rather than duplicating issue lists
across codebase maps.
