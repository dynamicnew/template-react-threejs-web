---
name: project-remember
description: Record a verified, durable project lesson in docs/ai/memory.md, a settled decision in docs/ai/decisions.md, or an open issue/question in docs/ai/concerns.md.
---

# Record a lesson

1. Confirm the fact is verified: you ran a check or read the source. Treat
   prior notes and memory as context to verify, not proof. If unverified or
   unresolved, record it in `docs/ai/concerns.md` (or as an unknown in
   `docs/ai/handoff.md`) instead.
2. Skip it if it is cheap to rediscover, specific to one task, or already
   covered. Inspect existing project docs, `docs/ai/memory.md`, and
   `docs/ai/concerns.md` first so you update the canonical record without
   creating duplicate or conflicting lists.
3. Add one verified lesson above `## Entry format` in `docs/ai/memory.md`: a
   one-sentence fact, the evidence (file, command, or commit), and today's date.
4. Put a settled choice that future work must respect in `docs/ai/decisions.md`,
   and put active open decisions, questions, flakes, or gaps in
   `docs/ai/concerns.md`. Keep durable shared decisions in reviewed repository
   docs, not only in session or expiring memory.
5. If a platform memory tool (such as Copilot Memory) is available, deduplicate
   against existing entries and use it only for appropriate scoped durable
   facts; do not claim storage succeeded unless the tool succeeded.
6. Keep project lessons in this repository. Do not modify user-level or other
   repositories' instruction or memory files without explicit authorization.
   Never record secrets, personal data, webhook URLs, raw transcripts, or
   guesses.
7. Remove or correct an entry that has stopped being true.
