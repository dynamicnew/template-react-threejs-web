# Read-list: review

Use for checking a diff or a plan.

- **Read:** the diff or files under review, the tests that cover them, and the
  rule or decision they are supposed to follow.
- **Do not read:** the whole handoff or unrelated modules.
- **Do not:** edit files or run mutating commands.
- **Check:** Three.js DPR/disposal/reduced-motion rules, Tailwind v4 semantic
  tokens, accessibility, brand/feature preservation, clean production copy (no
  leaked internal open decisions), `node_modules` hygiene, and Docker tests.
- **Return:** only findings you are confident about, each with file (line
  numbers are fine in ephemeral chat replies), problem, impact, and a suggested
  fix. Say plainly if there are none and what you could not verify.
