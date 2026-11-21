# AI project handoff

Updated YYYY-MM-DD. Read [todo.md](todo.md) and [concerns.md](concerns.md) with
this file.

## Current handoff

### Scope and repository state

- Feature branch (`feature/<topic>`), last verified commit, uncommitted work:
- What is built and verified (Docker build / unit / asset / component / E2E):
- What is built but unverified (real-hardware WebGL FPS / live external relay / CI run):

### Blockers and next actions

1. *(Link to open entries in [concerns.md](concerns.md) instead of duplicating issue lists.)*

### Checks and evidence limits

- Docker commands run, with exact pass/fail/skip counts and any flakes/retries:
- Not run, and why:

## Archived history

Dated archives, not current validation: see [handoff-history/](handoff-history/).

## Documentation maintenance

- Keep this file factual and under about 20 KB. Separate committed work,
  uncommitted work, historical results, proposals, and unknowns. Label
  historical results so they cannot be mistaken for fresh validation. Never
  include secrets, webhook URLs, personal data, raw transcripts, or guesses.
- Keep active open decisions, questions, approvals, flakes, and gaps
  consolidated in [concerns.md](concerns.md) and settled architectural choices
  in [decisions.md](decisions.md), not only in session or expiring memory.
- Move dated sections unchanged to `handoff-history/handoff-<date>.md`,
  repairing relative links without rewriting the historical narrative and
  leaving a one-paragraph summary and link. Keep `#current-handoff`,
  `#archived-history`, and `#documentation-maintenance` stable.
- At milestones and before interruption, update this file and any document it
  links to in the same change, and check the links.
