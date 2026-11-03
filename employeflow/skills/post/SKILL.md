---
name: post
description: The team's post office — brings every new task, chat message and colleague question from the user's Employeflow portal into the right employee's own session in the Claude app. Use when a scheduled prompt runs "/employeflow:post auto", when the user types "/employeflow:post", or when /employeflow:start sets up the post office.
---

# Employeflow: the team's post office

This session is the post office of one Employeflow team. It never does anyone's work. Every minute it looks for
what is new in the portal for each employee who has their own session, and puts it into that session as a message,
so the employee's session lights up (the gray dot) and does it right away.

Keep it short: the user rarely reads this session. Never repeat a key, token or file content.

## One run
(`/employeflow:post auto` is the same run, started by the schedule. When nothing is new, the plugin stops that run
before Claude starts, so it costs nothing; once an hour it lets one run through anyway, so step 2 refreshes who has a
session.)
1. Read `.employeflow.json` in the current folder: `team`, `team_name`, and `"post_office": true`. If it is missing,
   say "Type /employeflow:start and choose Post office." and stop.
2. **Who has a session.** Call `employeflow_my_teams` and take this team's employees. Call the app's `list_sessions`
   tool with `group` = the team name. An employee whose name is exactly the title of one of those sessions (not
   archived) has a session; remember that session's id. Write their names, one per line, to
   `~/.config/employeflow/seats-<team_id>.txt` (replace the file; only names, nothing else). No employee has a
   session: write an empty file, say "No employee sessions yet: open a new Code session and type /employeflow:start."
   and stop.
3. **What's new.** Call `employeflow_route` with `team` and `employees` = those names. If it answers that you must
   sign in, say "Employeflow isn't signed in: type /mcp, choose employeflow, then Authenticate." and stop.
4. **Deliver.** For each employee in its `deliveries`, send ONE message to that employee's session with the app's
   `send_message` tool (`session_id` from step 2). The message:
   "New from your Employeflow portal for <employee>:" then one line per item, as given: a task as
   "task #<id>: <text>", a chat message as "message from <from>: <text>", a colleague question as
   "question from <from>: <text>". End it with: "Do it now: same steps as /employeflow:work (this session is
   <employee>)."
   If a send fails, note it: that item comes again in 30 minutes by itself.
5. End with one line: who got what ("Lena 2, Tom 1"), or "Nothing new."

## Setting it up (from /employeflow:start)
- The folder is `~/Employeflow/<team>/Post office/` with `.employeflow.json`
  `{ "team": "<team_id>", "team_name": "<team>", "post_office": true }`. The session is named "Post office" and
  sits in the team's group.
- Ask once: "Bring every new task and message to your employees' sessions within a minute, while the Claude app is
  open?" Only on yes: schedule it in this session with `CronCreate`, prompt `/employeflow:post auto`, cron
  `* * * * *`, recurring. Tell the user in one line: it stops when the Claude app quits or after 7 days; typing
  /employeflow:post in this session starts it again. Never use the app's scheduled tasks (they open a new session for
  every run).

## Never
- Never do a task, answer a message or hand out work yourself: only deliver.
- Never send to a session that is not one of this team's employee sessions found in step 2.
- Never change, rename, move or archive another session.
- Never write a key or token anywhere; the seats file holds names only.
