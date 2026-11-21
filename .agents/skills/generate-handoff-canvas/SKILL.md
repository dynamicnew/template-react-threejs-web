---
name: generate-handoff-canvas
description: Generate or recreate a lean, read-only project-local handoff canvas panel (GitHub Copilot extension under .github/extensions/<canvas-id>/ or Antigravity MCP App side pane under .agents/plugins/<canvas-id>/) tailored for React + Tailwind v4 + Three.js + Docker projects without shipping prebuilt panel code in the template.
---

# Generate a project handoff canvas panel (React + Tailwind v4 + Three.js + Docker)

Build a lean, **read-only**, source-backed handoff panel that renders Git state,
branch comparison, handoff freshness, and `docs/ai/handoff.md` with themed
styling matching the project's design tokens. By default the panel cannot run
build, test, or Git write commands and is never a second handoff record.

Ask which host target is wanted if unclear: **Copilot canvas extension**
(`.github/extensions/<canvas-id>/`), **Antigravity MCP App side pane**
(`.agents/plugins/<canvas-id>/`), or both (plus whether optional `/canvases`
launcher or `docs/ai/todo.md` editing is requested).

## Target A: Copilot project-local canvas (`.github/extensions/<canvas-id>/`)

Place all files directly in a child folder under `.github/extensions/`
(`.github/extensions/<canvas-id>/extension.mjs` — 3 parent hops back to the Git
root; `<canvas-id>` is lowercase kebab-case, e.g. `<project>-handoff`). No
`package.json`, `npm install`, VSIX, or manifest is required: the Copilot host
discovers `extension.mjs` automatically and provides
`@github/copilot-sdk/extension`. Git must be on `PATH`.

Resolve the repository root from `extension.mjs` as:
`const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..", "..", "..");`

### Files to generate

| File | Responsibility |
|---|---|
| `settings.mjs` | Exports `CANVAS_ID`, `PROJECT_NAME`, `BASE_BRANCH` (default `"main"`), `HANDOFF_PATH` (`"docs/ai/handoff.md"`), and `MAX_HANDOFF_BYTES` (`256 * 1024`). |
| `extension.mjs` | Imports `{ CanvasError, createCanvas, joinSession } from "@github/copilot-sdk/extension"`. Tracks `instances = new Map()` (`instanceId -> { server, url }`). Starts one ephemeral loopback HTTP server (`server.listen(0, "127.0.0.1")`) per instance, reuses it on reopen, and closes server + `closeAllConnections()` in `onClose`. Serves `GET /`, `GET /api/status`, and `POST /api/open` only. Registers `createCanvas({ id, displayName, description, actions: [get_status], open, onClose })` and runs `await joinSession({ canvases: [canvas] })`. |
| `status.mjs` | Concurrent read-only `execFile("git", ..., { cwd: root, timeout: 10_000, windowsHide: true, maxBuffer: 1024 * 1024 })` (no shell): current feature branch (`rev-parse --abbrev-ref HEAD`), `status --short`, `status --porcelain=v1 -z` (skip extra rename/copy path after `[RC]`), `log -8 --format=%h %cs %s`, `@{upstream}`, `remote get-url origin` scrubbed via `githubOrigin()` to `https://github.com/<owner>/<repo>` (strip all credentials/non-GitHub URLs), ahead/behind vs `BASE_BRANCH` (`for-each-ref` preferring local ref + `rev-list --left-right --count`), and handoff freshness (`log -1 --format=%h%x09%cs%x09%H -- <HANDOFF_PATH>` + `rev-list --count <full>..HEAD`). Reads `HANDOFF_PATH` up to `MAX_HANDOFF_BYTES`; returns structured diagnostics instead of throwing. |
| `links.mjs` | Validated OS link opener for `POST /api/open` (`{ url }`). Permits only `http:`, `https:`, `mailto:`, `vscode://file/...`, and `file://` for a strict non-executable binary allowlist (`png|jpg|jpeg|gif|webp|ico|pdf|zip|mp3|mp4|wav`). Verifies `realpath(root)` + `realpath(target)` containment and `stat().isFile()`, rejects control chars, double-encoding, credentials, and Windows reserved device names (`con`, `prn`, `aux`, `nul`, `com1-9`, `lpt1-9`). **Critical:** strip `ELECTRON_*` env vars (`ELECTRON_RUN_AS_NODE`) before spawning `shell: false` (Windows: PowerShell `-EncodedCommand` `Start-Process`; macOS: `/usr/bin/open`; Linux: `xdg-open`, 10 s timeout). |
| `ui.mjs` | Exports `PAGE = String.raw\`<!doctype html>...\`` styled with the project's semantic color tokens (read from `docs/brand/identity.md` / `src/styles/main.css`), supporting `prefers-color-scheme: light/dark` and `prefers-reduced-motion: reduce`, with zero remote fonts or scripts and `__HANDOFF_ACTION_TOKEN__` replaced once per instance (avoid raw backticks inside the template literal). Build all DOM exclusively with `document.createElement` + `textContent` (never `innerHTML` on repo/Git text). Render: sticky header + accessible brand mark (decorative glyphs `aria-hidden="true"`) + Refresh, 4 snapshot cards (Branch + ahead/behind `main`, Working tree pills, Origin link, Handoff file), freshness banner (green `0` with beacon, amber `1-4`, alert `5+` commits since last handoff edit), collapsible Recent commits and Working tree lists, sticky section TOC + minimal Markdown renderer (headings, lists, tables, fenced code excluded from TOC, relative links resolved against `HANDOFF_PATH`'s folder), and footer quick-open buttons (`AGENTS.md`, `docs/ai/handoff.md`, `docs/ai/todo.md`, `docs/ai/concerns.md`, `docs/brand/identity.md`). Zero horizontal overflow at `380px`. |
| `README.md` | How to open, what it shows, safety invariants, file table, and the exact Docker smoke-test command. |
| `verify/panel-smoke.mjs` | Offline Playwright + server smoke test designed to run inside the project's `ui-tests` Docker image (`docker run --rm --network none --cap-drop ALL --security-opt no-new-privileges:true -v "${PWD}:/repo:ro" ...`): copies the extension and handoff into `/tmp/work`, writes a stub `@github/copilot-sdk/extension` and canned `git` shim in `/tmp/bin`, verifies `status.mjs` parsing + credential removal + freshness, `404` wrong capability, `403` bad host, `403` missing token, token injection, dark/light/`380px` screenshots + zero overflow + zero unexpected console/page errors, and clean `onClose`. |

### Optional modules (add only when requested)

- `canvas-launcher.mjs`: Registers `/canvases` via `joinSession({ canvases, commands })`
  using `session.rpc.canvas.list()`, `session.capabilities.ui?.elicitation`,
  `session.ui.select(...)`, and `session.rpc.canvas.open(...)` with a
  deterministic `instanceId` (`base64url(extensionId + "\0" + canvasId)`).
- `notes.mjs`: Fixed-path editor for `docs/ai/todo.md` (max 64 KiB, `lstat` +
  `nlink === 1n` symlink/hardlink rejection, SHA-256 optimistic HTTP `409`
  concurrency, serialized queue, exclusive lockfile, atomic rename). Never
  touches `docs/ai/handoff.md` or executes note text.

### Non-negotiable security invariants

1. Generate two 32-byte hex secrets (`randomBytes(32).toString("hex")`) per
   instance: URL `capability` (`/<capability>/`) and same-origin `token`
   (`x-handoff-token`), compared with `timingSafeEqual`.
2. Enforce `req.headers.host` equals `127.0.0.1:<port>` or `localhost:<port>`
   (`403` otherwise) and valid capability (`404` otherwise) before any route.
3. Require `x-handoff-token`, `origin === "http://" + host`, and
   `content-type === "application/json"` on `POST /api/open` (and any optional
   write route), with body size capped at 8 KiB.
4. Serve HTML with `cache-control: no-store`, `x-content-type-options: nosniff`,
   `referrer-policy: no-referrer`, and
   `content-security-policy: frame-ancestors 'self' vscode-webview: vscode-file: https://*.vscode-cdn.net`.

## Target B: Antigravity MCP App side-pane panel (`.agents/plugins/<canvas-id>/`)

Antigravity does not load `.github/extensions/*/extension.mjs`. Follow
Antigravity's built-in `mcp-app-development` skill to build a workspace plugin
in `.agents/plugins/<canvas-id>/` (`plugin.json`, `mcp_config.json` with a
Stdio server using `${PLUGIN_ROOT}` in `args` and `${PLUGIN_DATA}` for any
writable state — never relative CWD, literal secrets, or hardcoded user paths).
Reuse `status.mjs` (and optional `notes.mjs`), placing those modules directly
inside `.agents/plugins/<canvas-id>/` when generating Target B standalone
without Target A. Serve a self-contained `ui://<canvas-id>/handoff.html`
(`text/html;profile=mcp-app`, built with `@modelcontextprotocol/ext-apps` and
themed with the project's tokens), and register an empty-arg entry tool with
`_meta["com.google.antigravity/ui"].entrypoints` (`aux_pane` / `global`).

## Verification before completion

1. Rebuild `ui-tests` if needed and run `verify/panel-smoke.mjs` inside Docker
   with `--network none` and the repository mounted `:ro` (never host-native as
   equivalent Docker acceptance). If the Docker Linux engine or `ui-tests`
   image is not yet available (for example, during initial pre-Docker
   bootstrap), report Docker verification as blocked/pending rather than
   claiming a pass.
2. Confirm all security checks (`404`/`403`), credential scrubbing, freshness
   states, dark/light/`380px` zero-overflow screenshots, zero unexpected console
   errors, and clean `onClose` teardown.
3. Report live-host registration and native OS editor link opening as
   unverified unless tested live.
