# Employeflow channel proof

`push.sh` is a small [Claude Code channel](https://code.claude.com/docs/en/channels-reference) server: it lets the
Employeflow portal push "new work is waiting" into an employee's running Claude Code session within seconds, instead
of the plugin's every-minute check.

- Plain `sh` + `curl`, nothing to install.
- It answers the few MCP requests Claude Code sends (`initialize`, `ping`, `tools/list`) and declares the
  `claude/channel` capability.
- Every 5 seconds it asks the portal, with the team's count-only check key, how much is waiting for the employee of
  the current folder (`.employeflow.json`). The key can only count; it never reads a task or a message.
- When something new is waiting it pushes one `notifications/claude/channel` event with no task text. The session
  then fetches the work itself, with the owner's own sign-in (`/employeflow:work`).
- A check that finds nothing costs no Claude turn.

**Not part of the plugin.** During the channels research preview only Anthropic-approved channel plugins may push, so
this runs only in a terminal with the development flag:

```bash
claude --dangerously-load-development-channels server:employeflow-push
```

with an `.mcp.json` in the employee's folder:

```json
{ "mcpServers": { "employeflow-push": { "command": "sh", "args": ["/full/path/to/push.sh"] } } }
```
