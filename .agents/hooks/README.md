# Hooks

No hooks are enabled. Hooks run shell commands synchronously during the agent
loop, so add one only for a measured need (for example, blocking a destructive
command).

In Antigravity, workspace hooks are configured in `.agents/hooks.json` (not in
this folder) using named hook entries with events `SessionStart`, `PreToolUse`,
`PostToolUse`, `PreInvocation`, `PostInvocation`, or `Stop`. Handlers use
`"type": "command"`, receive camelCase JSON on stdin, and return JSON on stdout.

If you add a hook, document here:

- what it does and when it runs,
- what it reads or changes,
- how to turn it off (for example, `"enabled": false` in `.agents/hooks.json`).

Never put secrets in a hook file or script.
