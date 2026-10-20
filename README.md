# Employeflow plugin for Claude Code

This plugin connects your own Claude Code to your **Employeflow** team portal ([employeflow.com](https://employeflow.com)).

In the portal you write tasks and chat messages for your AI employees, for example "Tom: cut video #4". With this
plugin, your Claude picks that work up, does each item in the role of the employee it is addressed to, and reports
the result back to the portal's Results.

It runs on your computer, with your own Claude plan. Employeflow never sees or stores your Claude login.

## What you need

- **Claude Code**: the **Code** tab in the Claude desktop app, or `claude` in a terminal.
- An **Employeflow portal** and its **connect code**: in your portal open the **Connect** tab, click
  **Create connect code**, then **Copy code only (for the Claude plugin)**. **You only need the code itself: the part
  that starts with `efb_`.** It is shown once, so keep it until the plugin has it. Ignore the Connect tab's
  "Download the connector" and "Copy the command instead" buttons: they are for a different way of connecting, and the
  plugin needs only the `efb_…` code. A stray space at either end, or a line break at the end, is fine; it is trimmed. A line break at the start or in the
  middle is not: paste the code again as one line.
- **Windows only:** [Git for Windows](https://gitforwindows.org), which gives Claude Code the `sh` and `curl` the
  plugin's idle check uses. Windows support has not been fully tested yet.

## Install

> **"Successfully installed" does not mean the plugin is connected.** It also needs your connect code (step 3).
> Without it the plugin does nothing, and every check stops with "no connect code set".

**In the Claude app:** open the **Code** tab, start a session in any folder, and type into the message box:

1. ```
   /plugin marketplace add employeflow/plugins
   ```
2. ```
   /plugin install employeflow@employeflow
   ```
   Claude Code shows what the plugin contains and asks you to confirm.
3. Paste your connect code (only the `efb_…` part) when Claude Code asks for it. If it doesn't ask, type
   `/plugin configure employeflow@employeflow` and paste it there.
4. Start a **new session** (a new chat in the Code tab), so the plugin is loaded, and type `/employeflow:work`.
   The first time, Claude asks whether it may use the Employeflow tools: choose **Allow**.

Claude Code keeps the connect code in your system's secure storage (the macOS Keychain), never in a plain file. To
change it later, type `/plugin configure employeflow@employeflow` again.

### Terminal only

If you use `claude` in a terminal instead of the app, give the code with the install command. There is no
`claude plugin configure` terminal command, so the code can only be given here or later inside a Claude Code session:

```
claude plugin marketplace add employeflow/plugins
```

```
claude plugin install employeflow@employeflow --config team_key=efb_YOUR_CODE
```

Read what it prints. If it says `--config not applied` (for example "Failed to save sensitive plugin options to
secure storage"), the plugin is installed but has **no connect code**, even though the command still succeeds. You
can also see it afterwards: `/employeflow:work` answers "Employeflow isn't connected yet", and a scheduled
`/employeflow:work auto` stops with "no connect code set". Start `claude` and type
`/plugin configure employeflow@employeflow` to set it.

## Check that it works

Type `/employeflow:work`. You see your team's work, "nothing waiting", or "Employeflow isn't connected yet": then the
connect code is missing or wrong. Copy only the `efb_…` part again and set it again.

Scheduled runs (see below) say it before Claude starts, at no cost to your plan:

| The scheduled run stops with | What it means |
|---|---|
| "no connect code set" | No code is set. Set it as in step 3. |
| "the connect code looks like a whole command line" | The whole line from the Connect tab was pasted. Paste only the part that starts with `efb_`. |
| "the connect code has a line break in it" | A line break got into the code when it was pasted. Set it again as one line. |
| "connect code rejected (401)" or "(403)" | The code is wrong or no longer valid. Create a new one in the Connect tab and set it again. |
| "nothing waiting" | Connected; your portal has no open work right now. |
| "the portal did not answer" | No connection to employeflow.com; nothing was checked. |

In `/mcp` the `employeflow` connector is missing while no code is set, and shows "Server rejected" with a wrong code.

## Use it

Type:

```
/employeflow:work
```

Claude asks your portal what is waiting, does each task as the right employee, and reports back. It ends with one
line: tasks done, tasks failed, chats answered. If the portal didn't accept a report, that line says **not reported**
with the reason, and the result file stays in your folder; such a task doesn't count as done.

**Checking automatically.** Ask Claude to "check my Employeflow every 15 minutes". It offers a scheduled task in the
Claude app with the prompt `/employeflow:work auto`, and creates it only if you say yes. Scheduled tasks run while
the app is open and the computer is awake.

When a scheduled check finds nothing waiting, the plugin stops it before Claude starts, so empty checks use none of
your Claude plan. Only runs that find work use your plan.

Finished work is kept in the folder you run it in:

- `Employeflow/<Employee>/results/`: one file per task.
- `Employeflow/<Employee>/NOTES.md`: what each employee learned, read again on the next run.

## What it sends, and what it doesn't

The plugin talks to one address only: `https://employeflow.com/api/mcp`, with your connect code.

**It sends:**

- Your **connect code**, with every request.
- A **task id** when Claude starts a task.
- The **result you report** when a task is done or failed: the result itself, or a short summary plus where the file
  is (at most 600 characters).
- Each **chat reply** Claude writes as an employee.

**It does not send:** your other prompts, your files, your transcripts, or your Claude login. Result files stay in
your folder; only the summary Claude reports goes to the portal. Employeflow drops any result or reply that looks
like a password or key before storing it.

**The idle check.** The plugin adds a hook that runs on your computer before Claude reads a prompt. It only acts on the
exact prompt `/employeflow:work auto`: then it asks your portal "how much is waiting?" (connect code only, nothing else),
and stops the prompt if the answer is zero. Every other prompt passes through untouched and is never sent anywhere.
You can read it in [`employeflow/bin/peek.sh`](employeflow/bin/peek.sh).

## What it adds to Claude Code

| Part | File | What it does |
|---|---|---|
| Connector `employeflow` | [`employeflow/.mcp.json`](employeflow/.mcp.json) | Four tools: read your team's open work, start a task, finish a task, reply to a chat |
| Skill `work` | [`employeflow/skills/work/SKILL.md`](employeflow/skills/work/SKILL.md) | How Claude does one run (the `/employeflow:work` command) |
| Hook | [`employeflow/hooks/hooks.json`](employeflow/hooks/hooks.json), [`employeflow/bin/peek.sh`](employeflow/bin/peek.sh) | The idle check described above |
| Settings | [`employeflow/.claude-plugin/plugin.json`](employeflow/.claude-plugin/plugin.json) | One setting, your connect code (stored as `team_key`), marked sensitive |

Claude Code keeps the plugin under `~/.claude/plugins/`. The connect code is a **sensitive** setting: Claude Code
stores it in your system's secure storage (the macOS Keychain), not in a plain file.

The plugin never starts anything on its own. Work only runs when you type `/employeflow:work`, or from a scheduled
task you created yourself.

## Uninstall

```
/plugin uninstall employeflow@employeflow
```

Optionally remove the marketplace too:

```
/plugin marketplace remove employeflow
```

If you created a scheduled task for `/employeflow:work auto`, delete it in the Claude app as well. Your result files
and notes stay in your folder. Claude Code may keep an unused copy of the plugin files in
`~/.claude/plugins/cache/employeflow/`; it no longer loads, and you can delete that folder.

Uninstalling does not switch off your connect code. To have a code switched off, write to us (below).

## Questions and security reports

[support@employeflow.com](mailto:support@employeflow.com)
