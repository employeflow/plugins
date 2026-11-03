---
name: start
description: Make this Claude session one employee of the user's Employeflow team — connect, pick the team, pick the employee, name the session after them, file it under the team in the sidebar, do that employee's waiting work and turn on the automatic check. Use when the user says "/employeflow:start", "start my Employeflow team", "set up Employeflow", "connect Employeflow", "add an employee session", or has just added the Employeflow plugin.
---

# Employeflow: this session becomes one employee

**Set up by the team's setup** (the prompt is `/employeflow:start auto`): this session was created by the team lead's
session, and `.employeflow.json` in this folder already says who it is. Ask nothing: do step 6 (name and team group),
step 7 (the key file is normally there already), and then:
- an employee (`as_employee`): step 8 (their waiting work); no automatic check of its own when the file says
  `"post_office_ready": true` or the team has a session titled "Post office"; finish with one line "<employee> is ready."
- the post office (`"post_office": true`): its `CronCreate` as in the `post` skill's "Setting it up" without asking
  again when the file says `"every_minute": true` (the owner said yes during the setup); run the `post` skill once;
  finish with one line "Post office is delivering: new work reaches your employees within about 15 seconds while the
  Claude app is open. It stops when the app quits or after 7 days; type /employeflow:post here to start it again."

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
   is that employee: say "This session is <employee> on <team>." and ask whether to keep it (then go on at step 6;
   for the team lead that also offers step 6b, the rest of the team) or change it (go on at step 3). Never change it
   without a yes.
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
6b. **The rest of the team, by itself** (only when this session is the team lead, the one marked "leads" in
   `employeflow_my_teams`; on a team where nobody is marked "leads", in the first session of the team, when no other
   session has the team's name as its group yet). Call `list_sessions` with `group` = the team name. Every employee of the team with no
   session titled with their name, and the post office if no session is titled "Post office", is missing. If none
   is missing, skip this step. Otherwise ask once: "Set up the others too: <names> and the Post office? Each gets its
   own session, named and filed under <team>, and the Post office brings them new work within a minute while the
   Claude app is open." Only on yes, for each one that is missing:
   1. Make its folder as in step 5 (the post office: `~/Employeflow/<team>/Post office/`) and write its
      `.employeflow.json` there with full paths: an employee `{ "team": "<team_id>", "team_name": "<team>",
      "as_employee": "<name>", "post_office_ready": true }`, the post office `{ "team": "<team_id>", "team_name":
      "<team>", "post_office": true, "every_minute": true }`.
   2. Start its session with the app's `start_session` tool: `initiation` "user_asked", `context` "fresh",
      `use_worktree` false, `cwd` = that folder, `title` = the employee's name (or "Post office"), `prompt`
      `/employeflow:start auto`, and as `background`: "Employeflow: this session is <name> on the team <team>,
      set up by the team lead's session at the owner's request. Its folder's .employeflow.json says who it is."
   Employees first, the Post office last. If the app has no `start_session` tool, open the app's new-session screen
   for each one instead (`open "claude://code/new?folder=<folder, url-encoded>&q=%2Femployeflow%3Astart%20auto"`)
   and tell the user to press Enter once in each. Then say in one line who was set up ("Lena, Jonas, Sara, Tom, Mia
   and the Post office are being set up: each one names itself and joins <team> in a moment.").
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
- Never rename, move or group any session but this one ("self"). Sessions this setup starts (step 6b) name and
  file themselves.
- Never start a session for anyone but a missing employee of this team or its post office, and only after the
  owner's yes in step 6b.
- Never schedule anything without the user's yes.
