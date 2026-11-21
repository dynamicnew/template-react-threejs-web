---
name: verification-before-completion
description: Run fresh Docker checks and inspect runtime health before claiming work is fixed, healthy, passing, or complete, distinguishing container software-WebGL passes from real-hardware or live-relay acceptance.
---

# Verification before completion

Evidence before claims. A passing test command is evidence about that command,
not proof that every viewport, theme, real GPU, or deployed webhook works.

## Match evidence to the claim

Before editing, define the user-visible outcome and smallest relevant Docker
verification. Rebuild Docker images after code/style/asset changes; never fall
back to host-native tests or claim unrun suites passed.

| Claim | Required evidence |
|---|---|
| Production build passed | Fresh Docker `tools` build output (`validate:catalog` + `vite build`), exit `0` |
| Unit / schema tests passed | Exact Docker `tools` command and pass/fail counts |
| Asset integrity verified | Fresh Docker asset/hash check confirming manifest SHA-256 and LF endings |
| Component fixture passed | Isolated Docker component browser suite pass/fail counts (not full-app routing) |
| Root E2E passed | Fresh Docker `ui-tests` run across desktop, mobile, and theme modes with zero unexpected console/request errors |
| Hardware / live relay worked | Real GPU frame-rate check or live deployed endpoint (never inferred from software WebGL or local queue fallback) |
| Docs-only change verified | Relative link check, `git diff --check`, and context-size check |

## Check runtime health alongside assertions

- Start console, uncaught-exception, page-crash, failed-request, and HTTP
  status observation before page navigation across all routes and themes.
- A retry passing does not erase an intermittent flake; report retries and
  flakes explicitly and track recurring instability in `docs/ai/concerns.md`.
- Confirm no `node_modules/` entries are tracked in Git.
- Verify no internal open decisions or unfinished-work commentary leaked into
  production UI copy.

## Verify, clean up, and report

1. Rebuild and run the required Docker jobs after the final meaningful edit.
2. Read full output, exit codes, pass/fail/skip counts, chunk warnings, and
   any retries.
3. For delegated work, verify subagent diffs and exact Docker outputs yourself
   before accepting or committing on the feature branch.
4. Remove temporary files or debug outputs. Never record webhook secrets or
   private data in reports or docs.
5. Report exact commands, counts, flakes, and unverified limits plainly. If
   runtime evidence contradicts green tests, switch to
   [systematic-debugging](../systematic-debugging/SKILL.md).
