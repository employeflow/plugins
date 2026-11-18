# Employeflow plugin for Claude Code

This plugin lets your own Claude work for your **Employeflow** AI team ([employeflow.com](https://employeflow.com)).

In the portal you write tasks and chat messages for your AI employees, for example "Tom: cut video #4". With this
plugin, your Claude picks that work up, does each item in the role of the employee it is addressed to, and reports
the result back to the portal's Results.

It runs on your computer, with your own Claude plan. Employeflow never sees or stores your Claude login.

**Install in the Claude app (four clicks).** Open **Settings → Plugins**, click **Add** (top right), paste
`employeflow/plugins`, then click **Add to this computer** next to **Employeflow**. Typing `/plugin` in a chat opens the
same screen; just carry on there. Then, in a new **Code** session, type `/employeflow:start`.

**In a terminal, one line:**

```
claude plugin install employeflow --marketplace employeflow/plugins
```

(Claude Code 2.1.275 or newer; older versions use the two lines further down.) **Help:** open **Support** at the bottom right of any page on
[employeflow.com](https://employeflow.com), or email support@employeflow.com.

## What you need

- **Claude Code**: the **Code** tab in the Claude desktop app, or `claude` in a terminal.
- **A Claude plan for business:** your company's Claude **Team** or **Enterprise** plan, or (in a terminal) your company's
  own Anthropic API key. Claude Pro and Max are personal plans, and Anthropic's terms don't allow them for business use.
- An **Employeflow account** ([employeflow.com](https://employeflow.com)) that owns a team or is a member of one.
  You sign in with it once; there is no code to copy.

## Start in 4 steps

1. **On [employeflow.com](https://employeflow.com):** sign up and build your team.
2. **In the Claude app:** open **Settings → Plugins** (German: **Einstellungen → Plugins**), click **Add**
   (**Hinzufügen**), enter `employeflow/plugins`, then click **Add to this computer** (**Zu diesem Computer hinzufügen**).
   Typing `/plugin` in a chat opens the same screen.
3. **Connect once.** In a new Code session type `/mcp`, choose **employeflow**, click **Authenticate**, sign in on
   employeflow.com and click **Allow**. (Use `/mcp`, not the Settings page.)
4. **Type `/employeflow:start` and pick your team lead.** Claude names this session after them and files it under your
   team in the sidebar. Then it offers once to set up everyone else and the Post office: say yes. Each one gets its own
   session, names itself, joins your team and starts on its waiting work. (If your Claude app can't open sessions by
   itself, it opens a new-session screen for each one: press Enter once in each.) To add someone later, open a new
   Code session, type `/employeflow:start` and pick them.

That's it: one session per employee, each one named and grouped under your team. What you give an employee in the
dashboard (skills, the team handbook, your team's own skills, what the team may reach) reaches that employee's session
by itself, and someone you hire later gets their own session from the Post office. The Post office brings each new task
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

- **inbox-replies**: answers new emails. Each reply waits in your portal's Approvals first; only one you approve
  becomes a Gmail draft, with exactly the approved text. A declined reply never reaches Gmail.
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

The plugin talks to one address only: `https://employeflow.com/api/mcp`, our server, which is also the plugin's declared connector. You sign in on employeflow.com in your browser; Claude Code receives only a sign-in token for your account. Your Claude login never reaches us.

**What your Claude sends, when it uses the plugin's tools:**
- your **sign-in token**, the **team** (and, in an employee's folder, the **employee**) from `.employeflow.json`, and the plugin's version, with every request;
- when a task starts: its **task id**; when it ends: the **result** (or a summary plus where the file is, at most 600 characters) and, for a text result file (.md .txt .csv .json .html), its **name and text** (at most 100,000 characters);
- each **chat reply** an employee writes to you;
- **approval requests**: a title (at most 300 characters), the **exact draft** that would go out, such as an email reply or a post (at most 20,000), and, if it answers a customer, **the customer's own words** (at most 2,000), so you can approve, edit or decline it in your portal's Approvals;
- **questions between employees** and their answers (at most 2,000 characters each), shown in your Team Chat and passed to the colleague's session;
- **progress on a team goal** (a number and one line, at most 300 characters), an employee's **one-line plan** when they ready up for a goal (at most 300), and **finished deliverables** (a title and a two-line summary with where they are);
- from the **Boss's session only**, when you agree it there: a **goal** (title, number and unit, date, who answers for it, who works on it) and **work you give one or two employees** (one line, details at most 2,000 characters);
- when the Boss hands out a task you gave him: each part (the employee, a one-line task, its details).

**Personal data:** when an employee works with your own Gmail, Google Drive or Calendar connectors in Claude (inbox replies, invoices, meeting prep), the results, drafts and the customer's words above can contain names, email text and amounts from your accounts. They are stored in your portal (EU) for as long as your account exists, or until you delete them.

**After every turn (0.12):** in an employee's session (not the post office), the plugin tells the portal that this employee is working when a prompt starts, and when the turn ends it sends **numbers only**, read from that session's own transcript on your computer: the model, token counts (input, cache, output), how many model calls, and when the turn began and ended. Nothing of the conversation is sent, not even a title or the first line of a prompt. It uses the count-only key and never blocks anything.

**The automatic checks:** `/employeflow:start` stores a **count-only key** in `~/.config/employeflow/` (readable only by you). A small script (`bin/peek.sh`) runs before a scheduled `/employeflow:work auto` or `/employeflow:post auto` prompt and asks our server "how much is waiting?" with that key, the plugin version and, for the post office, **the names of the employees that have a session**. The post office asks up to 4 times a minute (every 15 seconds) while the Claude app is open. Nothing waiting: the prompt stops before Claude starts, so it uses none of your plan. Every other prompt passes untouched and is never sent anywhere.

**It does not send:** your other prompts, any other file, your transcripts, or your Claude login. Employeflow refuses any result, reply or file that looks like a password or key, and stores nothing of it.

**Nothing goes out without you.** Employees never send, post, publish or pay anything themselves: things meant for the outside world become drafts in your Approvals, and you decide. Results and chat replies go into your own portal only.

The portal decides what a signed-in account may do: only teams you own or are a member of, only the folder's
employee's work, and on a team that runs on its owner's own Claude only the owner hands out work.

## What it adds to Claude Code

| Part | File | What it does |
|---|---|---|
| Connector `employeflow` | [`employeflow/.mcp.json`](employeflow/.mcp.json) | Tools for your teams and open work, starting and finishing a task, chat replies, the employee's skills, handing out and routing work (the Boss), setting goals, giving work to one or two employees and the team's status (the Boss's session, yours only), asking you for approval and reading your decision, asking and answering a colleague, goal progress and readying up, handing in a deliverable, and the count-only key |
| Skill `start` | [`employeflow/skills/start/SKILL.md`](employeflow/skills/start/SKILL.md) | Make this session one employee: connect, pick the team and the employee, turn on the automatic check (`/employeflow:start`) |
| Skill `post` | [`employeflow/skills/post/SKILL.md`](employeflow/skills/post/SKILL.md) | The team's post office: brings new work into the right employee's session (`/employeflow:post`) |
| Skill `work` | [`employeflow/skills/work/SKILL.md`](employeflow/skills/work/SKILL.md) | How Claude does one run (`/employeflow:work`) |
| Skills `inbox-replies`, `invoices`, `meeting-prep`, `social-posts`, `weekly-report` | [`employeflow/skills/`](employeflow/skills/) | Ready-made jobs; anything meant for the outside world becomes a draft for your approval |
| Skill `setup` | [`employeflow/skills/setup/SKILL.md`](employeflow/skills/setup/SKILL.md) | Older command; points to `/employeflow:start` |
| Hooks | [`employeflow/hooks/hooks.json`](employeflow/hooks/hooks.json), [`employeflow/bin/peek.sh`](employeflow/bin/peek.sh), [`employeflow/bin/turn.sh`](employeflow/bin/turn.sh) | The free idle check: before a scheduled `/employeflow:work auto` or `/employeflow:post auto` it asks the portal (count-only key) whether anything is waiting, and stops the run if not. Every other prompt passes untouched. `turn.sh`: the turn report above (numbers only) |

The plugin never starts anything on its own. Work only runs when you type `/employeflow:work`, or from a scheduled
task you created yourself.

## Upgrading from 0.1 or 0.2

Since 0.2 the plugin signs in with your account instead of a connect code. After the update, type
`/employeflow:start` once. Your old connect code is no longer used by the plugin.

## Uninstall

In the Claude app: open **Settings → Plugins** and remove **Employeflow** there (and, if you like, the
`employeflow/plugins` marketplace). In a terminal:

```
claude plugin uninstall employeflow@employeflow
claude plugin marketplace remove employeflow
```

If you created a scheduled task for `/employeflow:work auto`, delete it in the Claude app as well. Your folders,
result files and notes stay where they are; you can delete `~/.config/employeflow/`.

## Questions and security reports

Open **Support** at the bottom right of any page on [employeflow.com](https://employeflow.com) and write us there.
For a security report, start your message with "Security". Or email [support@employeflow.com](mailto:support@employeflow.com).
