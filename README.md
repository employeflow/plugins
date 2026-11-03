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

## Start in 4 steps

1. **On [employeflow.com](https://employeflow.com):** sign up and build your team.
2. **In the Claude app:** open **Settings → Plugins** (German: **Einstellungen → Plugins**), click **Add**
   (**Hinzufügen**), enter `employeflow/plugins`, then click **Add to this computer** (**Zu diesem Computer hinzufügen**).
3. **Connect once.** In a new Code session type `/mcp`, choose **employeflow**, click **Authenticate**, sign in on
   employeflow.com and click **Allow**. (Use `/mcp`, not the Settings page.)
4. **Type `/employeflow:start` and pick your team lead.** Claude names this session after them and files it under your
   team in the sidebar. Then it offers once to set up everyone else and the Post office: say yes. Each one gets its own
   session, names itself, joins your team and starts on its waiting work. (If your Claude app can't open sessions by
   itself, it opens a new-session screen for each one: press Enter once in each.) To add someone later, open a new
   Code session, type `/employeflow:start` and pick them.

That's it: one session per employee, each one named and grouped under your team. The Post office brings each new task
and message to the right employee's session within about a minute while the Claude app is open; a check that finds
nothing costs nothing. New tasks you give an employee in
the portal are picked up by that employee's session while the Claude app is open, and the results appear in your
portal's Results. Whether each employee's session checked in, and when, is shown on the portal.
Checks that find nothing waiting stop before Claude starts, so they use none of your Claude plan.

In a terminal instead of the app: `claude plugin marketplace add employeflow/plugins`, then
`claude plugin install employeflow@employeflow`, then start `claude` and type `/employeflow:start`.

## What your employees can do

Besides the tasks you write in the portal, five job skills come with the plugin. Each one only writes drafts and
hands the result back to your portal; nothing is sent, posted or paid:

- **inbox-replies**: answers new emails as Gmail drafts.
- **invoices**: a monthly overview of your invoices from Gmail and Google Drive, with unusual ones flagged.
- **social-posts**: a week of post drafts in your company's tone.
- **meeting-prep**: a one-page brief for your upcoming meetings.
- **weekly-report**: your team's week on one page, with what needs you.

They use your own Gmail, Google Drive and Google Calendar connectors when you have turned them on in your Claude
(Settings → Connectors). The plugin brings no connectors of its own.

## Day to day

- Type `/employeflow:work` any time to do what's waiting right now.
- Finished work is kept in each employee's folder, `~/Employeflow/<team>/<employee>/`: `Employeflow/<Employee>/results/`
  (one file per task) and `Employeflow/<Employee>/NOTES.md` (what the employee learned).
- The 15-minute check runs inside the employee's session. It stops when you quit the Claude app (and after 7 days):
  type `/employeflow:work` in that session to start it again.
- **Updates.** The Claude app does not fetch a newer version of this plugin by itself. When one exists, your portal's
  status line and the automatic check say so. To update: open a Code session, type `/employeflow:work` and say yes when
  Claude offers the update (it runs `claude plugin marketplace update employeflow`, then
  `claude plugin update employeflow@employeflow`), then restart the Claude app. Removing and adding the plugin again is
  not enough: the app keeps the old copy.
- To sign out: type `/mcp`, choose **employeflow**, then **Clear authentication**.

## If something doesn't work

| You see | What it means |
|---|---|
| "Connect Employeflow first" | Do step 3: `/mcp` → employeflow → Authenticate, in a new session. |
| "Create your team on employeflow.com first" | Your account has no team yet. |
| "Type /employeflow:start to pick your team" | Your account reaches several teams; start picks one for this folder. |
| "nothing waiting" | Connected; no open work right now. |

## What it sends, and what it doesn't

The plugin talks to one address only: `https://employeflow.com/api/mcp`. Signing in happens in your browser on
employeflow.com; Claude Code only receives a sign-in token for your account.

**It sends:**

- Your **sign-in token**, with every request, plus the **team** (and, in an employee's folder, the **employee**) from
  `.employeflow.json`, and the plugin's version.
- For the automatic check: a **count-only key** that `/employeflow:start` stores in `~/.config/employeflow/` (readable
  only by you). It can only ask "how much is waiting for this team?", nothing else, and stops working when your account
  no longer reaches the team.
- A **task id** when Claude starts a task.
- The **result you report** when a task is done or failed: the result itself, or a short summary plus where the file
  is (at most 600 characters).
- The **result file** of a finished task, when it is a text file (.md .txt .csv .json .html, at most 100,000
  characters): its name and its text, so you can open it in your portal's Results. Nothing else from your folder.
- Each **chat reply** Claude writes as an employee.
- When the Boss hands out a task you gave him: each part (the employee, a one-line task, its details), so it becomes
  a task for that employee in your portal.

**Nothing goes out without you.** The employees never send, post, publish or pay anything themselves, even when your
Claude has a Gmail or social media connector: they write drafts and hand them back to your portal, and you send.

**It does not send:** your other prompts, any other file, your transcripts, or your Claude login. Employeflow refuses
any result, reply or file that looks like a password or key, and stores nothing of it.

The portal decides what a signed-in account may do: only teams you own or are a member of, only the folder's
employee's work, and on a team that runs on its owner's own Claude only the owner hands out work.

## What it adds to Claude Code

| Part | File | What it does |
|---|---|---|
| Connector `employeflow` | [`employeflow/.mcp.json`](employeflow/.mcp.json) | Seven tools: your teams, the open work, start a task, finish a task, reply to a chat, (for the Boss) hand a part of a task to an employee, and the count-only key |
| Skill `start` | [`employeflow/skills/start/SKILL.md`](employeflow/skills/start/SKILL.md) | Connect, pick the team, do the waiting work, turn on the automatic check (`/employeflow:start`) |
| Skill `setup` | [`employeflow/skills/setup/SKILL.md`](employeflow/skills/setup/SKILL.md) | Optional: one folder per employee (`/employeflow:setup`) |
| Skill `work` | [`employeflow/skills/work/SKILL.md`](employeflow/skills/work/SKILL.md) | How Claude does one run (`/employeflow:work`) |
| Hook | [`employeflow/hooks/hooks.json`](employeflow/hooks/hooks.json), [`employeflow/bin/peek.sh`](employeflow/bin/peek.sh) | The free idle check: before a scheduled `/employeflow:work auto` it asks the portal (count-only key) whether anything is waiting, and stops the run if not. Every other prompt passes untouched and is never sent anywhere |

The plugin never starts anything on its own. Work only runs when you type `/employeflow:work`, or from a scheduled
task you created yourself.

## Upgrading from 0.1 or 0.2

Since 0.2 the plugin signs in with your account instead of a connect code. After the update, type
`/employeflow:start` once. Your old connect code is no longer used by the plugin.

## Uninstall

```
/plugin uninstall employeflow@employeflow
```

Optionally remove the marketplace too:

```
/plugin marketplace remove employeflow
```

If you created a scheduled task for `/employeflow:work auto`, delete it in the Claude app as well. Your folders,
result files and notes stay where they are; you can delete `~/.config/employeflow/`.

## Questions and security reports

Open **Support** on [employeflow.com](https://employeflow.com) (bottom right of every page). Our support mailbox is not set up yet.
