# Employeflow plugin for Claude Code

Connect your own Claude to your Employeflow team with one command. Your team's tasks and messages from your
Employeflow portal are picked up by your own Claude, done in each employee's role, and the results are reported
back to your portal. Nothing goes out without your approval.

## Install (Claude desktop app, Code tab, or Claude Code)

```
/plugin marketplace add employeflow/plugins
/plugin install employeflow@employeflow
```

Claude asks for your **team key**: copy it from the Connect tab in your Employeflow portal. It's stored in your
system keychain, never in a file.

## What it does
- Adds an Employeflow connector (`https://employeflow.com/api/mcp`) so Claude can fetch your team's work and
  report results.
- Adds the `work` skill: take a task → do it as the employee → save the result → report back.
- A small check only wakes Claude when there is work waiting (an empty check uses no Claude usage).

Runs on your own Claude plan or your own API key. https://employeflow.com
