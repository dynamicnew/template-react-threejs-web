---
name: systematic-debugging
description: Investigate real application failures, WebGL/Three.js issues, CSS theme/a11y regressions, catalog asset hash mismatches, API relay errors, or intermittent E2E flakes before changing code.
---

# Systematic debugging

Find the root cause of the observed failure, not just a way to make assertions
pass. Follow [AGENTS.md](../../../AGENTS.md) and Docker-only test rules. This
skill grants no permission to deploy, weaken assertions, or remove existing
features.

## Establish the actual environment

- Read `#current-handoff` in [docs/ai/handoff.md](../../../docs/ai/handoff.md)
  and relevant entries in [docs/ai/concerns.md](../../../docs/ai/concerns.md).
- Confirm whether the failure occurred in Docker `tools`, Docker `ui-tests`
  (software WebGL), Docker preview, local Vite dev server, or a deployed host.
  Remember Docker images copy the working tree — confirm images were rebuilt
  after the latest edit.
- Check line endings (CRLF vs LF) first when generated SVG/HTML/JSON asset
  hashes fail on Windows checkouts.

## Collect evidence before editing

1. Reproduce the symptom inside the matching Docker container. If external
   access (such as a live webhook or real GPU) blocks reproduction, report the
   blocker instead of fabricating data.
2. Observe browser console errors, uncaught exceptions, page crashes, failed
   network requests, and HTTP 4xx/5xx responses before navigation.
3. For Three.js / WebGL issues, check `devicePixelRatio` cap, `stateRef` sync,
   reduced-motion pause behavior, disposal on unmount, and fallback rendering
   when WebGL context creation fails.
4. For API/client relay issues, distinguish `4xx` validation rejections from
   `503`/`502`/network unavailability and inspect exact status/error codes.
5. Read full error stacks, inspect recent diffs, and trace the faulty value
   backward through its callers.

## Test one hypothesis at a time

- Compare a working route/theme/viewport with the failing one.
- State one evidence-backed hypothesis and run the smallest Docker suite that
  can disprove it (passing `--workers=2` when container PID limits apply).
- Fix the cause, not the symptom: do not add arbitrary sleeps, globally silence
  console errors, or weaken contrast/a11y/hash checks.
- If a test flakes intermittently (for example, software-WebGL CPU contention),
  verify isolation vs parallel runs and record the unverified cause honestly in
  `docs/ai/concerns.md`.
- If three distinct attempts fail, stop and report what was ruled out and what
  remains unknown.

## Clean up and verify

Remove temporary diagnostics and follow
[verification-before-completion](../verification-before-completion/SKILL.md)
before claiming the fix is complete.
