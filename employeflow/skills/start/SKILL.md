---
name: start
description: Start the user's Employeflow team in this Claude app — connect, pick the team, do the waiting work, and turn on the automatic check. Use when the user says "/employeflow:start", "start my Employeflow team", "set up Employeflow", "connect Employeflow", or has just added the Employeflow plugin.
---

# Employeflow: start my team

One command that sets everything up. Keep every message to the user short and plain: they are a business owner, not a
developer. Never repeat a key, token or file content in your messages.

1. **Connected?** Call `employeflow_my_teams`.
   - If the Employeflow tools aren't available or the answer says to sign in, say in one line: "Connect Employeflow
     first: Settings → Plugins → Employeflow → Connectors → employeflow → Connect (or type /mcp, choose employeflow,
     Authenticate), sign in and click Allow, then type /employeflow:start again." Stop. (Claude cannot start the
     sign-in itself, 2 Nov 2026.)
   - "No team on this account yet": say "Create your team on employeflow.com first, then type /employeflow:start
     again." Stop.
2. **Which team.** One team: use it, don't ask. Several: show them as a short numbered list (team name only) and ask
   which one this Claude should work for.
3. **Remember it.** Write `.employeflow.json` in the current folder: `{ "team": "<team_id>", "team_name": "<team>" }`
   (no `as_employee`: this session works the whole team, each task in its employee's role). If the file exists with a
   different team, ask before changing it.
4. **Free automatic checks.** Call `employeflow_peek_key` with the team id. Write the `peek_key` from its answer with
   one shell command (the key only goes into a private file; don't repeat it in your messages): `umask 077; mkdir -p ~/.config/employeflow && printf '%s'
   '<peek_key>' > ~/.config/employeflow/peek-<team_id>.key`. It can only count waiting work; it lets an empty check
   stop before Claude starts. If this fails, go on: checks then just cost a short Claude turn.
5. **Do what's waiting.** Run the `work` skill once now (same steps as /employeflow:work), for the whole team.
6. **Turn on the automatic check.** Ask once: "Check for new work automatically every 15 minutes while the app is
   open?" Only on yes: create a scheduled task (the app's scheduled-tasks tool) named "Employeflow", prompt
   `/employeflow:work auto`, every 15 minutes, in this folder. If no such tool exists, tell the user to ask "check my
   Employeflow every 15 minutes" in the Claude app's chat, or to type /employeflow:work when they want.
7. **Finish** with one line: "Done. New tasks from your portal are picked up automatically while the Claude app is
   open, and results appear in your portal's Results."

## Never
- Never repeat the peek key in your messages, and never write it anywhere but `~/.config/employeflow/`.
- Never create a scheduled task without the user's yes.
- Never create folders per employee here (that is `/employeflow:setup`, an optional extra for busy teams).
