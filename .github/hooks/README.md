# Hooks

No hooks are enabled. Hooks run shell commands automatically during agent
execution, so add one only for a measured need (for example, blocking a
destructive command).

In GitHub Copilot, repository hooks live in `.github/hooks/*.json` using
`"version": 1` and a `"hooks"` object mapping lifecycle events (`sessionStart`,
`preToolUse`, `postToolUse`) to command handlers (`"type": "command"`, `"bash"`,
and `"powershell"` or `"windows"`).

If you add a hook, document here:

- what it does and when it runs,
- what it reads or changes,
- how to turn it off (for example, `"disableAllHooks": true`).

Never put secrets in a hook file or script.
