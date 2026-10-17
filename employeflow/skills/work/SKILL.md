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

## One run
(`/employeflow:work auto` is the same run, started by the schedule.)
1. Call `employeflow_my_work`. If it says nothing is waiting, or the team is paused, say so in one line
   and stop.
2. For each **TASK** (in the order given):
   1. Call `employeflow_start_task` with its id.
   2. Read the employee's notes, if they exist: `Employeflow/<Employee>/NOTES.md` in the current folder.
      They hold what this employee learned in earlier runs.
   3. Do the task as that employee (their role is listed in the work). Keep the result in the current
      folder under `Employeflow/<Employee>/results/` (one file per task, named after the task).
   4. Call `employeflow_finish_task` with the result, or a two-line summary plus the file path. If you
      could not do it, call it with `failed: true` and the reason.
   5. Add one dated line to `Employeflow/<Employee>/NOTES.md`: what you did and anything worth
      remembering next time.
3. For each **CHAT** message: answer as the employee it is addressed to, with `employeflow_reply_chat`.
   Use the employee's notes when they help.
4. End with one line: how many tasks done, how many failed, how many chats answered.

Respect the team goals shown in the work: when a task belongs to a goal, keep that goal in mind.

## Checking automatically
If the user wants their team's work done without asking each time, offer to create a **scheduled task**
in the Claude app (it runs while the app is open and the computer is awake):
- prompt: `/employeflow:work auto` (exactly this: the word `auto` lets the plugin check the portal first, so a
  run with nothing waiting stops before Claude starts and uses none of the user's plan)
- schedule: every 15 minutes (only runs that find work use the user's Claude plan)
- folder: the folder they keep their Employeflow work in

Create it only when the user asks for it or agrees to it. Never set up anything else that runs on its own.

## Never
- Never ask for or handle the user's Claude login, API keys, or passwords. The connector already has
  what it needs.
- Never report a task as done that you didn't do. A result that says where the work is beats a
  long summary.
