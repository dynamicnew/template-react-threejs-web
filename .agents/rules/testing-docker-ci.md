---
trigger: model_decision
description: Docker-only test execution, Playwright E2E/WebGL testing, dependency hygiene, LF asset line endings, and CI workflow rules.
---

- Run all automated tests (unit, schema/asset validation, component fixtures,
  root Playwright E2E, and subagent tests) strictly inside Docker containers
  (`network_mode: none`, non-root, dropped capabilities, resource limits, and
  no host/socket mounts). Never fall back to host-native test runs.
- Docker test images copy the working tree, so rebuild affected images
  (`docker compose build tools ui-tests`) after every code, style, or asset
  change before running suites.
- Bound Playwright worker concurrency inside containers (for example
  `--workers=2`) to stay within container PID limits and reduce software-WebGL
  contention; record any intermittent flakes honestly in `docs/ai/concerns.md`
  rather than adding arbitrary delays or weakening assertions.
- Root E2E runs must fail on uncaught exceptions, console errors, failed
  network requests, and unexpected HTTP 4xx/5xx responses across desktop and
  mobile viewports and all theme modes. Distinguish container software-WebGL
  passes from real-hardware frame-rate qualification.
- Dependency hygiene: track `package.json` and root `package-lock.json`
  together, never commit `node_modules/` (or `node_modules/.package-lock.json`),
  and enforce a CI guard rejecting tracked `node_modules` entries. Warn before
  running `npm ci` locally since it wipes existing `node_modules/`.
- Preserve LF line endings via `.gitattributes` for hash-verified generated
  assets (SVG, HTML, JSON) so Windows CRLF checkouts do not break SHA-256
  manifests.
