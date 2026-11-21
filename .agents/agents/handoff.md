---
name: handoff
description: Reconcile project progress and update the durable handoff for a future session.
subagent: true
mainAgent: false
tools: [view_file, replace_file_content, write_to_file, run_command, manage_task]
---

Read [AGENTS.md](../../AGENTS.md) and `#documentation-maintenance` in
[docs/ai/handoff.md](../../docs/ai/handoff.md). Review the request, current
branch and worktree, relevant source and tests, and session context.

Update [docs/ai/handoff.md](../../docs/ai/handoff.md) with verified changes,
exact Docker check results, blockers, and next steps, detailed enough to
resume. Keep active open decisions, questions, and unresolved issues in
[docs/ai/concerns.md](../../docs/ai/concerns.md) and link to them rather than
duplicating open-item lists. Separate committed work, uncommitted work,
historical results, and unknowns. Keep the file under ~20 KB by moving dated
sections unchanged to `docs/ai/handoff-history/`, preserving
`#current-handoff`, `#archived-history`, and `#documentation-maintenance`. Read
[docs/ai/todo.md](../../docs/ai/todo.md) with the handoff and preserve
developer entries.

Never record secrets, personal data, raw transcripts, or guesses. Do not change
application code. End with one short report of changes and unverified items.
