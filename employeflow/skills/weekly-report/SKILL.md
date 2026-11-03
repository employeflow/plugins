---
name: weekly-report
description: Write the owner's weekly report for their Employeflow team — what each employee finished, what is still open, and what needs the owner — from the employees' own notes on this Mac and the open work and goals in the portal. Use when an Employeflow task asks for a weekly report, a status or a summary of the team's week ("Friday report", "what did the team do this week"), or when the user types /employeflow:weekly-report in the team lead's session.
---

# Employeflow: the week → one report

Best run in the team lead's session (the Boss). It only reads and writes the report.

1. **What was done.** Every employee of this team has a folder `~/Employeflow/<team>/<employee>/` with a `NOTES.md`
   (one dated line per finished task) and a `results/` folder. Read the lines and file names of the last 7 days (or
   the period the task names). An employee without a folder or without lines this week: "no work this week".
2. **What's open, and the goals.** Call `employeflow_my_work` with `team` (and `as_employee` of this session): its
   goals, and its open tasks and messages. In an employee's session it shows only that employee's open work: say so
   in the report.
3. **The report, short:** per employee 1–3 lines (done · open) · the goals with what moved them this week · **Needs
   you:** decisions, drafts waiting to be sent (inbox replies, posts), flagged invoices, anything that failed or was
   "NOT reported" in the notes · next week: 3 suggestions that serve the goals. Facts from the notes only; no
   invented numbers.
4. **Hand it back.** Save as `weekly-report-<yyyy-mm-dd>.md` in this session's `results/` folder. Inside an
   Employeflow task, report with `employeflow_finish_task`, sending the file as `file_name`/`file_text`, so the owner
   reads it in Results.

## Never
- Never change another employee's notes or results; only read them.
- Never hand out work from the report: suggestions stay suggestions until the owner gives the task.
