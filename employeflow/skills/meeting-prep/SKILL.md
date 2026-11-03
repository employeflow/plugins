---
name: meeting-prep
description: Prepare a one-page brief for the owner's upcoming meetings from Google Calendar, with the related emails and Drive documents, without changing the calendar or contacting anyone, and hand it back to the Employeflow portal. Use when an Employeflow task asks to prepare a meeting, a call or tomorrow's appointments ("prep my 10 o'clock", "brief me for tomorrow's meetings"), or when the user types /employeflow:meeting-prep in an employee's session.
---

# Employeflow: meeting → one-page brief

You work as the employee of this session (`.employeflow.json`, `as_employee`), for the owner's company.

**Nothing is changed or sent.** Never accept, decline, move or create a calendar event, and never email or message
a participant.

1. **Which meeting.** The one the task names. If it names none: the owner's meetings of the next working day (from
   the Google Calendar connector in their Claude), at most 5. If there is no Calendar connector and the task gives
   no meeting, say in one line "Connect Google Calendar in your Claude (Settings → Connectors), or name the meeting
   in the task." and, inside a task, finish it as failed with that reason.
2. **Material.** For each meeting: the invitation text, the participants (names and companies as written), and,
   when Gmail or Google Drive is connected, the last emails with those participants and documents named after the
   meeting or its topic (read only, the newest 5 at most).
3. **The brief, one page per meeting:** when and where (or the link) · who comes and what we know about them from
   the material · what it's about · what happened last time · 3 open questions or decisions for the owner · what to
   bring or have open. Facts only from the material; mark guesses as guesses. No research about private persons
   beyond what the material says.
4. **Hand it back.** Save as `meeting-brief-<yyyy-mm-dd>.md` in the employee's `results/` folder. Inside an
   Employeflow task, report with `employeflow_finish_task`, sending the file as `file_name`/`file_text`.
5. Add one dated line to the employee's `NOTES.md`.

## Never
- Never change a calendar, reply to an invitation or contact a participant.
- Never put passwords, meeting PINs or dial-in codes into the brief beyond what the owner needs to join.
- Never look up private details about participants outside the owner's own material.
