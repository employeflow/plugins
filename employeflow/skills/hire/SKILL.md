---
name: hire
description: Hire a ready-made employee / Fertige Mitarbeiter einstellen — the owner asks what employees they can hire, or names a ready-made job ("what employees can I hire?", "I want an ads manager", "I need someone for customer service", "ich will einen Werbe-Manager", "wen kann ich einstellen?"). Lists the ready-made roles, hires the one the owner picks in three short steps, and starts its own session. Only in the Boss's session, only on the owner's own words.
---

# Employeflow: hire a ready-made employee

Only in the Boss's (team lead's) session (`.employeflow.json` with `as_employee` "Boss", or a whole-team session), and
only on what the owner says **in this chat**. Speak the owner's language and keep it plain: no tool names, no
"MCP", no "API", no "connector" when "connection" will do.

## When the owner asks what they can hire
Call `employeflow_roles` (`lang` = the owner's language). Show the ready ones, one line each (name · what it does
for them · the one connection), then the "coming soon" names in one line. End with: "Tell me which one you want."
Never list them unasked. During `/employeflow:start` a role may be mentioned **at most once**, and only when it is
exactly what the owner said they need.

## The three steps
**1 · The owner asks for one** ("I want an ads manager").
- Not ready yet (`employeflow_roles` says coming soon): say so in one line, and offer a general employee for the
  job instead (the start skill's step 6a for one person).
- Ready: say in two or three lines what this employee does, what always waits for their yes, and the one
  connection it needs. Then ask only what the role needs to start:
  - **a name** (offer one: "Shall I call him Max?");
  - **for a role that spends money (Ads Manager): the monthly limit**, "What's the most it may spend on ads in a
    month, in euros? It plans every month below that and never proposes anything above it. For a hard stop on Meta's
    side too, you can set an account spending limit in your Meta billing settings: a running total that pauses all
    your ads when it is reached, and that you reset yourself, for example each month." Take the number the owner says,
    never one you suggest. Say: "Every launch, pause and budget change still waits for your yes."
- On their yes call `employeflow_add_employee`:
  - `name`, `role` = the role's name, `job` = the role's job line (from `employeflow_roles`);
  - `role_pack` = its slug (e.g. `ads-manager`);
  - `monthly_limit_eur` = the owner's number (for a role that spends money);
  - leave `tools` and `level` out: the role brings its own level. The Ads Manager works at "Asks, then does it":
    everything waits for the owner's yes, then he does it himself. Say that in one plain sentence.

**2 · It introduces itself.** Start its own session exactly as the start skill's step 6b says, for this one
employee. Its first run (the role's "First day") introduces it, names the one connection and checks it.

**3 · It does the job.** Tell the owner in one line where they'll see it: "Max reports to you every Monday; whatever
he wants to do waits in your approvals, just ask me 'what's waiting?'".

## Never
- Never hire a role the owner didn't ask for, and never suggest one twice.
- Never pick or raise a monthly limit yourself; only the owner's own number.
- Never promise results ("more sales", "cheaper customers"). Say what the employee does, not what it will achieve.
