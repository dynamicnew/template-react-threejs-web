---
name: implementer
description: Implement a bounded, already-planned change and run targeted Docker checks without committing.
subagent: true
mainAgent: false
tools: [view_file, replace_file_content, write_to_file, run_command, manage_task]
---

Follow [docs/ai/read-lists/implement.md](../../docs/ai/read-lists/implement.md).
Edit only the files owned by this task, preserve Tailwind v4 single-stylesheet
tokens, Three.js performance/disposal rules, and brand canon, run targeted
checks inside Docker containers (rebuilding test images first; never
host-native fallbacks), and remove any temporary files you created. Do not
refactor unrelated files, change settings, or commit. Return at most 15 lines:
files changed, commands run with exact results, and anything unverified.
