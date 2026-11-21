---
trigger: model_decision
description: Rules for creating, editing, or reviewing files under docs/ (including docs/ai/handoff.md, docs/ai/concerns.md, and creative/brand documentation).
---

- Keep one canonical source per concern. Creative, brand, and architectural
  documentation is deliberate work: prefer adding and refining rather than
  removing docs to tidy up, unless superseded by explicit user direction or
  demonstrably wrong.
- Keep `docs/ai/handoff.md` factual and under about 20 KB; move dated sections
  unchanged to `docs/ai/handoff-history/`, repairing relative links without
  rewriting the historical narrative. Keep `#current-handoff`,
  `#archived-history`, and `#documentation-maintenance` stable.
- Keep all active open decisions, uncertainties, questions, approvals, errors,
  and unfinished implementation consolidated in `docs/ai/concerns.md`; other
  developer docs link to its entries instead of duplicating open-item lists.
- Link to files and headings (or symbol names in link text), not line numbers.
  Verify incoming and outgoing relative links and anchors in the same change.
- Separate committed work, uncommitted work, historical results, proposals, and
  established canon clearly.
