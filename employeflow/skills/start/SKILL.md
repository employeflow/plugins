---
name: start
description: Make this Claude session one employee of the user's Employeflow team — connect, pick the team, pick the employee, name the session after them, file it under the team in the sidebar, do that employee's waiting work and turn on the automatic check. Use when the user says "/employeflow:start", "start my Employeflow team", "set up Employeflow", "connect Employeflow", "add an employee session", or has just added the Employeflow plugin.
---

# Employeflow: this session becomes one employee

One session = one employee. Each employee of the team gets its own session in the Claude app, named after them and
filed under the team in the sidebar. This session works only its own employee's tasks and messages.

Keep every message to the user short and plain: they are a business owner, not a developer. Never repeat a key,
token or file content in your messages.

1. **Connected?** Call `employeflow_my_teams`.
   - If the Employeflow tools aren't available or the answer says to sign in, say in one line: "Connect Employeflow
     first: type /mcp, choose employeflow, click Authenticate, sign in on employeflow.com and click Allow. Then type
     /employeflow:start again." Stop. (Claude cannot start the sign-in itself. Don't send the user to the app's
     Settings page for this: a sign-in started there waits for whichever session is open in the window and can look
     disconnected, measured 3 Nov 2026.)
   - "No team on this account yet": say "Create your team on employeflow.com first, then type /employeflow:start
     again." Stop.
2. **Already an employee?** If `.employeflow.json` in the current folder has an `as_employee`, this session already
   is that employee: say "This session is <employee> on <team>." and ask whether to keep it (then go on at step 6) or
   change it (go on at step 3). Never change it without a yes.
3. **Which team.** One team: use it, don't ask. Several: show them as a short numbered list (team name only) and ask.
4. **Which employee.** Show the team's employees as a short numbered list: name and role, the team lead first,
   and as the last line "Post office (brings every new task and message to your employees' sessions within a
   minute; one per team)". Before you show it, call the app's `list_sessions` tool (if this app has it) with
   `group` = the team name: an employee whose name is the title of one of those sessions already has a session; mark
   it "has a session" (and the post office, if a session is titled "Post office"). Ask which one this session is. If
   the user picks one that has a session, say so and ask again (open that session to work with them).
   **Post office chosen:** do steps 5–7 with the folder `~/Employeflow/<team>/Post office/`, the file
   `{ "team": "<team_id>", "team_name": "<team>", "post_office": true }` and the session name "Post office"; then
   follow "Setting it up" in the `post` skill, run the `post` skill once, finish with "Done. This is your team's
   post office: new tasks and messages reach your employees' sessions within a minute while the Claude app is
   open." and stop.
5. **Their own folder.** Each employee works in its own folder:
   `~/Employeflow/<team>/<employee>/` (names as shown, with `/` and `\` replaced by `-` and leading dots removed; a
   name that is then empty becomes `team` or `employee`; if two employees of the team would get the same folder, add
   `-2` to the second). Create it and write `.employeflow.json` there:
   `{ "team": "<team_id>", "team_name": "<team>", "as_employee": "<employee name>" }`.
   - If this session is already in that folder, nothing more to do here.
   - Otherwise move this session there with the app's `change_directory` tool (the user approves the folder once).
     From here on use full paths: the move takes effect when this turn ends.
   - If the app has no `change_directory` tool, or the user declines: say "Open a new Code session in the folder
     ~/Employeflow/<team>/<employee> and type /employeflow:start there." and stop.
6. **Name and team group.** Rename this session to the employee's name with the app's `set_session_title` tool
   (`session_id` "self"). Then call `list_groups`: if a group named exactly like the team exists, use it; otherwise
   create it with `create_group` (the team's name). Move this session into it with `move_sessions`
   (`session_ids` ["self"]). If the app has none of these tools, skip this step and say so in one line at the end.
7. **Free automatic checks.** Only if `~/.config/employeflow/peek-<team_id>.key` does not exist yet: call
   `employeflow_peek_key` with the team id and write the `peek_key` from its answer with one shell command (the key
   only goes into a private file; don't repeat it in your messages): `umask 077; mkdir -p ~/.config/employeflow &&
   printf '%s' '<peek_key>' > ~/.config/employeflow/peek-<team_id>.key`. One key serves every employee of the team, so
   never ask for a new one when the file is there. If this fails, go on: checks then just cost a short Claude turn.
8. **Do what's waiting.** Run the `work` skill once now (same steps as /employeflow:work), for this employee only.
   The folder move only takes effect after this turn, so pass `team` and `as_employee` from step 5 yourself on every
   Employeflow call, and write the employee's notes and results with full paths inside
   `~/Employeflow/<team>/<employee>/`.
9. **Turn on the automatic check.** If the team has a post office (a session titled "Post office" in the team's
   group, step 4), skip this step: say "The post office brings <employee>'s new work to this session." Otherwise ask
   once: "Check for <employee>'s new work every 15 minutes in this session
   while the app is open?" Only on yes: schedule it **in this session** with the `CronCreate` tool, prompt
   `/employeflow:work auto`, cron `7,22,37,52 * * * *`, recurring. Tell the user in one line that it stops when the
   Claude app quits or after 7 days, and that typing /employeflow:work in this session starts it again. Never use the
   app's scheduled tasks for this: they open a new session for every run, and this employee's work belongs in this
   session. If there is no `CronCreate` tool, tell the user to type /employeflow:work in this session when they want.
10. **Finish** with two short lines: "Done. This session is <employee> on <team>: their tasks from your portal are
    done here, and results appear in your portal's Results." and "For another employee, open a new Code session and
    type /employeflow:start." If the team has no post office yet, add: "Tip: one more session as Post office brings
    every new task and message here within a minute."

## Never
- Never make this session work for more than one employee (or both an employee and the post office), and never for
  an employee `employeflow_my_teams` did not list.
- Never repeat the peek key in your messages, and never write it anywhere but `~/.config/employeflow/`.
- Never write outside `~/Employeflow/` and `~/.config/employeflow/`.
- Never rename, move or group any session but this one ("self").
- Never schedule anything without the user's yes.
