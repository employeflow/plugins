---
name: setup
description: Set up Employeflow on this computer for a signed-in Employeflow account — one folder per team and one per employee, so each Claude session works for exactly one employee. Use when the user says "set up my Employeflow folders", "/employeflow:setup", "connect all my teams", or right after signing in to Employeflow.
---

# Employeflow: one folder per team, one per employee

A signed-in Employeflow account can reach every team it owns or is a member of. This sets up folders so that a
Claude session opened in an employee's folder works only for that employee (the portal enforces it).

1. Call `employeflow_my_teams`. If it says it is for a signed-in account, tell the user in one line: "Sign in to
   Employeflow first: type /mcp, choose employeflow, Authenticate, then run /employeflow:setup again." and stop.
2. Show the teams in a short list (team, owner or member, employees). Ask which teams to set up; the default is all.
3. In the current folder create `Employeflow/<team>/<employee>/` for each employee of the chosen teams. Use the names as
   shown, with `/` and `\` replaced by `-` and leading dots removed; a name that is then empty becomes `team` or
   `employee`. Never write outside `Employeflow/`. In each employee folder write `.employeflow.json`:
   `{ "team": "<team_id>", "team_name": "<team>", "as_employee": "<employee name>" }`
   If the file already exists with a different `team`, ask before changing it. Create nothing else.
4. Finish with: "Open a new Claude Code session in an employee's folder and type /employeflow:work — that session works
   only for that employee. The Boss's folder plans tasks and hands them out." Mention the folder path once.

## Never
- Never create folders for a team or employee that `employeflow_my_teams` did not list.
- Never write a sign-in token, password or key into any file.
