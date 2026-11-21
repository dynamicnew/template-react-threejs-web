---
applyTo: ".github/extensions/**,.agents/plugins/**"
description: Architecture, security, theming, and Docker verification rules for project-local handoff canvas panels.
---

- Load the `generate-handoff-canvas` skill before creating a handoff canvas
  panel from scratch.
- Keep the panel read-only by default (no build, test, or Git write execution)
  and keep `docs/ai/handoff.md` and `docs/ai/concerns.md` as the sole sources
  of truth; never create a parallel handoff record.
- For Copilot extensions (`.github/extensions/<canvas-id>/extension.mjs`), keep
  a direct child folder under `.github/extensions/` (3 parent hops back to Git
  root; no `package.json`/VSIX), bind only
  `127.0.0.1:0` per `instanceId`, close all connections in `onClose`, enforce
  `Host` (`403`) + `timingSafeEqual` capability (`404`) + same-origin
  `x-handoff-token` on writes (`403`), build DOM via `textContent` only (no
  `innerHTML`, zero remote fonts/scripts), scrub Git remote credentials,
  validate OS links via `realpath` + non-executable allowlist, and strip
  `ELECTRON_*` before spawning link handlers.
- Match the project's semantic color tokens with `prefers-color-scheme` and
  `prefers-reduced-motion: reduce`, keep decorative brand glyphs `aria-hidden`,
  and ensure zero horizontal overflow at `380px`.
- For Antigravity side panes (`.agents/plugins/<canvas-id>/`), use an MCP App
  (`ui://` `text/html;profile=mcp-app`, `@modelcontextprotocol/ext-apps`,
  `aux_pane` entrypoint) with no secrets or machine-local paths.
- Verify via `verify/panel-smoke.mjs` inside the Docker `ui-tests` container
  (`--network none`, repo `:ro`); never fall back to host-native tests.
