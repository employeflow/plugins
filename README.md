# Employeflow plugin for Claude Code

This plugin lets your own Claude work for your **Employeflow** AI team ([employeflow.com](https://employeflow.com)).

In the portal you write tasks and chat messages for your AI employees, for example "Tom: cut video #4". With this
plugin, your Claude picks that work up, does each item in the role of the employee it is addressed to, and reports
the result back to the portal's Results.

It runs on your computer, with your own Claude plan. Employeflow never sees or stores your Claude login.

## What you need

- **Claude Code**: the **Code** tab in the Claude desktop app, or `claude` in a terminal.
- An **Employeflow account** ([employeflow.com](https://employeflow.com)) that owns a team or is a member of one.
  You sign in with it once; there is no code to copy.

## Install

**In the Claude app:**

1. Open **Settings → Plugins** (German: **Einstellungen → Plugins**). Typing `/plugin` into a chat opens the same window.
2. Click **Add** (top right; German: **Hinzufügen**) and enter `employeflow/plugins`.
3. **Employeflow** now appears in the list. Click **Add to this computer** (German: **Zu diesem Computer hinzufügen**).
4. Start a **new session** and type `/mcp`. Choose **employeflow**, then **Authenticate**. Your browser opens
   employeflow.com: sign in if asked, then click **Allow**. Go back to Claude.
5. Type `/employeflow:setup`. It creates one folder per team and one per employee:
   `Employeflow/<team>/<employee>/`.

**In a terminal:**

```
claude plugin marketplace add employeflow/plugins
```

```
claude plugin install employeflow@employeflow
```

Then start `claude` and do steps 4 and 5 above.

Claude Code keeps the sign-in on your computer, in your system's secure storage (the macOS Keychain), and renews it
by itself. To sign out, type `/mcp`, choose **employeflow**, then **Clear authentication**.

## Use it

Open a new Claude Code session **in an employee's folder** (for example `Employeflow/My Team/Tom/`) and type:

```
/employeflow:work
```

That session works only for that employee: it sees only that employee's tasks and chats, does each one in that
role, and reports back. It ends with one line: tasks done, tasks failed, chats answered. If the portal didn't accept a
report, that line says **not reported** with the reason, and the result file stays in the folder; such a task doesn't
count as done. The Boss's folder plans the tasks you give the Boss and hands the parts to the employees.

**Checking automatically.** In an employee's folder, ask Claude to "check my Employeflow every hour". It offers a
scheduled task in the Claude app with the prompt `/employeflow:work auto`, and creates it only if you say yes.
Scheduled tasks run while the app is open and the computer is awake. Each check is a short Claude turn, also when
nothing is waiting, so check every hour rather than every few minutes.

Finished work is kept in the employee's folder: `results/` (one file per task) and `NOTES.md` (what the employee
learned, read again on the next run).

## Check that it works

| You see | What it means |
|---|---|
| "Employeflow isn't signed in" | Sign in as in step 4. |
| "This folder isn't an employee's folder yet" | Run `/employeflow:setup`, then open the session in an employee's folder. |
| "nothing waiting" | Signed in; this employee has no open work right now. |
| "no team … on your account" | The folder names a team your account can't reach (any more). Run `/employeflow:setup` again. |

In `/mcp` the `employeflow` connector shows **needs authentication** until you sign in.

## What it sends, and what it doesn't

The plugin talks to one address only: `https://employeflow.com/api/mcp`. Signing in happens in your browser on
employeflow.com; Claude Code only receives a sign-in token for your account.

**It sends:**

- Your **sign-in token**, with every request, plus the **team and employee** of the folder (from `.employeflow.json`).
- A **task id** when Claude starts a task.
- The **result you report** when a task is done or failed: the result itself, or a short summary plus where the file
  is (at most 600 characters).
- The **result file** of a finished task, when it is a text file (.md .txt .csv .json .html, at most 100,000
  characters): its name and its text, so you can open it in your portal's Results. Nothing else from your folder.
- Each **chat reply** Claude writes as an employee.
- When the Boss hands out a task you gave him: each part (the employee, a one-line task, its details), so it becomes
  a task for that employee in your portal.

**It does not send:** your other prompts, any other file, your transcripts, or your Claude login. Employeflow refuses
any result, reply or file that looks like a password or key, and stores nothing of it.

The portal decides what a signed-in account may do: only teams you own or are a member of, only the folder's
employee's work, and on a team that runs on its owner's own Claude only the owner hands out work.

## What it adds to Claude Code

| Part | File | What it does |
|---|---|---|
| Connector `employeflow` | [`employeflow/.mcp.json`](employeflow/.mcp.json) | Six tools: your teams, your employee's open work, start a task, finish a task, reply to a chat, and (for the Boss) hand a part of a task to an employee |
| Skill `setup` | [`employeflow/skills/setup/SKILL.md`](employeflow/skills/setup/SKILL.md) | Creates the team and employee folders (`/employeflow:setup`) |
| Skill `work` | [`employeflow/skills/work/SKILL.md`](employeflow/skills/work/SKILL.md) | How Claude does one run (`/employeflow:work`) |
| Hook | [`employeflow/hooks/hooks.json`](employeflow/hooks/hooks.json), [`employeflow/bin/peek.sh`](employeflow/bin/peek.sh) | The idle check of the older connect-code version; with sign-in it lets every prompt pass |

The plugin never starts anything on its own. Work only runs when you type `/employeflow:work`, or from a scheduled
task you created yourself.

## Upgrading from 0.1 (connect code)

Version 0.2 signs in with your account instead of a connect code. After the update: do steps 4 and 5 above, then run
`/employeflow:work` in an employee's folder. Your old connect code is no longer used by the plugin.

## Uninstall

```
/plugin uninstall employeflow@employeflow
```

Optionally remove the marketplace too:

```
/plugin marketplace remove employeflow
```

If you created a scheduled task for `/employeflow:work auto`, delete it in the Claude app as well. Your folders,
result files and notes stay where they are.

## Questions and security reports

Open **Support** on [employeflow.com](https://employeflow.com) (bottom right of every page). Our support mailbox is not set up yet.
