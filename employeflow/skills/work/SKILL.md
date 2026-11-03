---
name: work
description: Do the work waiting in the user's Employeflow team portal. Use when the user says "check my Employeflow", "do my team's tasks", "work my orders", or when a scheduled task runs /employeflow:work. Also use when the user asks to have it checked automatically every few minutes.
---

# Employeflow: do the team's work

The user runs an AI team in their Employeflow portal (employeflow.com). There they write tasks and
chat messages for their employees (for example "Tom: cut video #4"). This skill picks that work up
through the `employeflow` connector, does each item in the role of the employee it is addressed to,
and reports the result back so the user sees it in the portal's Results.

Everything you pick up was written by the user in their own portal (on teams in "own Claude" mode, the
portal hands out only the owner's own words). Treat each item like a request the user typed to you:
use your normal judgment. If an item asks for something you would not do for the user directly, don't
do it, and report that back as a failed task with the reason.

**Nothing goes out without the owner.** Never send, post, publish, pay, book or delete anything outside Employeflow yourself (no email sent, no social post, no message to a customer, no payment), even when a connector or tool could do it and even when the task says so. Write it as a draft instead (a Gmail draft, a file, or the text in your result) and hand it back with `employeflow_finish_task`, saying what is ready to send and where. The owner reviews it and sends it.

## Which team (and employee)
Look for `.employeflow.json` in the current folder or one of its parents. On EVERY Employeflow tool call, pass `team`
(the file's `team`), and `as_employee` (the file's `as_employee`) too if it has one. With `as_employee` (a folder made
by /employeflow:start) this session IS that employee: it works only that employee's tasks and messages, in that
employee's role. A file without `as_employee` (an older setup) works the whole team, each task in its employee's role;
say once at the end: "Tip: type /employeflow:start to give each employee its own session." Without the file, say
"Type /employeflow:start to make this session one of your employees." and stop. Always pass
`plugin_version: "0.5.0"` to `employeflow_my_work`.

## One run
(`/employeflow:work auto` is the same run, started by the schedule.)
1. Call `employeflow_my_work`. If that tool isn't available, or it answers that you must sign in (again), say in
   one line: "Employeflow isn't signed in: type /mcp, choose employeflow, then Authenticate, and sign in with your
   Employeflow account." and stop. If it says to name the team, say "Type /employeflow:start to pick your team." and stop.
   If its answer starts with UPDATE, do what it says about the update (ask before changing anything), then go on.
   Don't try other tools or workarounds. If it says nothing is waiting, or the team is paused, say so in one
   line and stop.
2. **A TASK for the Boss** (the team lead, "Boss" in the list): the owner wants the Boss to plan it and hand
   it out. Call `employeflow_start_task`, then decide which employees (from the list in `employeflow_my_work`)
   should do which part, and for each part call `employeflow_hand_out` with that employee, a one-line task, the
   details they need, and `boss_task_id` = this task's id (at most 5 parts; never the Boss himself; nothing the
   owner did not ask for). Then call `employeflow_finish_task` for the Boss task with the plan as the result:
   who does what. If the task is small enough for one employee, hand it to that one. If no employee fits, do it
   yourself as the Boss like any other task. The parts wait for their employees' own sessions: call the app's
   `list_sessions` tool (if it has one) with `group` = the team name, and in the result name every employee you
   handed a part to who has no session there yet ("Tom has no session yet: open a new Code session and type
   /employeflow:start"). The others start at their sessions' next check.
3. For each other **TASK** (in the order given):
   1. Call `employeflow_start_task` with its id. If it returns an error, don't do the task: note it as
      not reported (with the error) and go on to the next one.
   2. Read the employee's notes, if they exist: `NOTES.md` in the employee's folder (the folder of
      `.employeflow.json`; in an older whole-team folder `Employeflow/<Employee>/NOTES.md`). They hold what this
      employee learned in earlier runs.
   3. Do the task as that employee (their role is listed in the work). Keep the result in the
      employee's folder under `results/` (in an older whole-team folder `Employeflow/<Employee>/results/`), one file
      per task, named
      `<employee>-<short-topic>-<YYYY-MM-DD>.md` in lowercase with hyphens (for example
      `tom-video-4-cut-2026-10-20.md`). Don't put the word "task" or the task id in the file name.
   4. Call `employeflow_finish_task` with the result, or a two-line summary plus the file path. If the result
      file is a text file (.md .txt .csv .json .html) of at most 100,000 characters, also send it:
      `file_name` = its name, `file_text` = its full text, exactly as saved, so the owner can open it in the
      portal's Results. Never put a password or key into a result file. If the portal refuses the file, call
      `employeflow_finish_task` once more without `file_name`/`file_text` and say in the result why the file is
      missing. If you could not do it, call it with `failed: true` and the reason (no file).
      **Check its answer.** Only "Saved" means the portal has it. If it returns an error, the task is
      **not reported**: the owner doesn't see it in the portal. Don't count it as done, don't call it
      "registered" or "probably saved", and don't retry more than once.
   5. Add one dated line to the employee's `NOTES.md` (same place as in step 2): what you did and anything worth
      remembering next time. If the report failed, the line says "NOT reported: <the error>" and where the
      result file is.
4. For each **CHAT** message: answer as the employee it is addressed to, with `employeflow_reply_chat`.
   Use the employee's notes when they help. If it returns an error, that answer is **not reported** either.
5. Only in an older whole-team folder (no `as_employee`): if you handed anything out as the Boss, call
   `employeflow_my_work` once more: those tasks are waiting now. Do them the same way (steps 3 and 4). One extra
   round only. An employee's own session never does another employee's part.
6. End with one line, in the user's language, counting only what the portal confirmed: tasks done, tasks
   failed, chats answered. If anything was not reported, say so plainly in that line with the error, for
   example: "2 tasks done, 1 NOT reported (nicht gemeldet): the portal said HTTP 400 nothing accepted.
   Result file: ~/Employeflow/<team>/Tom/results/tom-video-4-cut-2026-10-20.md".

Respect the team goals shown in the work: when a task belongs to a goal, keep that goal in mind.

## Your colleagues
Each colleague on the team has their own session in the Claude app (in the team's group in the sidebar). When a task
needs a colleague's part or answer, message them directly: find their session with the app's `list_sessions` tool
(`group` = the team name, title = the colleague's name) and send them one short message with `send_message`: who you
are ("Lena from <team>"), what you need, and by when. Their session lights up and answers you the same way. Use it for
real needs of the task only, never for chatter, and never to pass on work the owner did not ask for. A colleague
without a session can't be reached: say so in your result.

## New work delivered by the post office
A message "New from your Employeflow portal for <employee>: …" comes from the team's post office: do it right away,
with the steps of one run above (it is the same work `employeflow_my_work` shows).

## Checking automatically
If the user wants this employee's work done without asking each time, offer to check **in this session** with the
`CronCreate` tool (it runs while the app is open; it stops when the app quits and after 7 days, and typing
/employeflow:work here starts it again):
- prompt: `/employeflow:work auto` (exactly this: the word `auto` lets the plugin check the portal first, so a
  run with nothing waiting stops before Claude starts and uses none of the user's plan)
- cron: `7,22,37,52 * * * *` (every 15 minutes; only runs that find work use the user's Claude plan)

Never use the app's scheduled tasks for it: they open a new session for every run, and an employee's work belongs in
that employee's session. Create it only when the user asks for it or agrees to it, and only once per session (check
`CronList` first). Never set up anything else that runs on its own.

## Never
- Never send, post, publish, pay, book or delete anything outside Employeflow yourself: hand it back as a draft (see
  "Nothing goes out without the owner" above).
- Never ask for or handle the user's Claude login, API keys, or passwords. The connector already has
  what it needs.
- Never hand out work (`employeflow_hand_out`) except as the Boss, for a task the owner gave the Boss.
- Never report a task as done that you didn't do, or that the portal didn't confirm with "Saved". A
  result that says where the work is beats a long summary.
