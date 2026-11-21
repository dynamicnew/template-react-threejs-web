# Open issues, decisions and response register

Single developer-only register for active open decisions, uncertainties,
pending approvals, intermittent test flakes, and unfinished work. Other docs
and [handoff.md](handoff.md) link here rather than maintaining competing issue
lists. Never surface internal status or open decisions from this file inside
production UI copy.

- Assign stable IDs (`ISSUE-001`, `ISSUE-002`, ...) and retain an ID when its
  status changes.
- A blank answer remains unresolved; it is not permission to invent canon or
  silently drop a feature.
- Never record secrets, webhook URLs, tokens, or private personal data here.

## Active register

| ID | Category | Status | Summary | Evidence / Owner |
|---|---|---|---|---|
| `ISSUE-001` | *(decision / flake / gap / verification)* | Open | *(Describe the open question, limitation, or defect concisely.)* | *(File or check reference)* |

## Fill-in decision prompts (optional)

Group open user decisions here so the user can answer in one place:

```markdown
### Q1. Short decision title

Related: ISSUE-001.

- **Options:** A, B, or "Delegate within current constraints"
- **Your answer:**
- **Recommendation:** *(Suggested default with concise rationale.)*
```
