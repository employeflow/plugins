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
- **Your own Claude plan:** **Pro** or **Max** if you work alone, **Team** or **Enterprise** if more people use it, or (in a
  terminal) your own Anthropic API key. In the EU, if your employees handle your customers' personal data, Team or an API
  key comes with Anthropic's data processing agreement.
- An **Employeflow account** ([employeflow.com](https://employeflow.com)) that owns a team or is a member of one.
  You sign in with it once; there is no code to copy.

## Start in 4 steps

1. **On [employeflow.com](https://employeflow.com):** sign up. Build your team there, or let your Boss build it with you
   in step 4.
2. **In the Claude app:** open **Settings → Plugins** (German: **Einstellungen → Plugins**), click **Add**
   (**Hinzufügen**), enter `employeflow/plugins`, then click **Add to this computer** (**Zu diesem Computer hinzufügen**).
   Typing `/plugin` in a chat opens the same screen.
3. **Connect once.** In a new Code session type `/mcp`, choose **employeflow**, click **Authenticate**, sign in on
   employeflow.com and click **Allow**. (Use `/mcp`, not the Settings page.)
4. **Type `/employeflow:start` and pick your team lead.** Claude names this session after them and files it under your
   team in the sidebar. Then it offers once to set up everyone else and the Post office: say yes. Each one gets its own
   session, names itself, joins your team and starts on its waiting work. (If your Claude app can't open sessions by
   itself, it opens a new-session screen for each one: press Enter once in each.) To add someone later, tell your Boss
   ("I need someone for the invoices"), or open a new Code session, type `/employeflow:start` and pick them.

   **No team yet?** `/employeflow:start` makes it right in the chat, and that session becomes your Boss. He asks what
   eats your time every week and proposes employees: a name and a job each. He checks which of your tools are connected
   (Gmail, Google Drive, Calendar…) and says what's missing. On your yes he hires them and gives each one its own
   session.

   **Every employee works with all the tools you connected, and nothing goes out without you unless you move that employee to "Does it alone".** When an employee's
   session starts, it writes a small rule file into its own folder (`.claude/settings.json`; your Claude app asks you
   once to allow it), and from then on the Claude app itself enforces that employee's level. If you want, tell your Boss
   to lock someone to fewer tools ("lock Rosa to Gmail only"); the app then refuses that employee your other tools. Each
   employee has a level, which you can change any time by telling your Boss:
   - **Shows you first** (everyone starts here): it prepares; sending, posting and sharing are locked; you send or post
     it yourself.
   - **Asks, then does it:** it puts what would go out into your Approvals and does it after your yes, exactly as approved.
   - **Does it alone:** it sends and posts on its own and reports each one.

   **Paying and deleting always ask you first,** at every level: the Claude app asks you before such a tool runs. After 20
   good results at a level, your Boss offers you the next one; nothing changes without your yes. What the lock can't
   stop: you changing the file yourself, and a Claude add-on (a "mod") that approves calls. In the mode that never asks
   ("don't ask"), paying and deleting are refused instead of asked.

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

Besides the tasks you write in the portal, twelve job skills come with the plugin. Each one only writes drafts and
hands the result back to your portal; nothing is sent, posted or paid without your yes:

- **inbox-replies**: answers new emails. Each reply waits in your portal's Approvals first; only one you approve
  becomes a Gmail draft, with exactly the approved text. A declined reply never reaches Gmail.
- **invoices**: a monthly overview of your invoices from Gmail and Google Drive, with unusual ones flagged.
- **social-posts**: a week of post drafts in your company's tone.
- **meeting-prep**: a one-page brief for your upcoming meetings.
- **weekly-report**: your team's week on one page, with what needs you.
- **angebote** (quotes, German first): turns a customer inquiry into a quote from your own price list and template;
  prices and terms come only from your data (`firma.md` and your price list). It waits for your approval.
- **mahnungen** (payment reminders, German first): checks your open invoices each week and drafts the next step,
  Zahlungserinnerung → 1. Mahnung → 2. Mahnung. Each letter waits for your approval; no invented fees, no threats,
  interest only where the law allows it. It's a drafting tool, not legal advice.
- **morning-brief**: one short message each morning: what needs you, today's appointments, the important new emails,
  what the team did.
- **meeting-notes**: a transcript or notes become a summary, decisions and to-dos; each colleague's to-do is handed to
  that colleague as a task; a follow-up email waits for your approval.
- **lead-follow-up**: answers new inquiries fast and follows up after 3 and 7 days, then stops; every email waits for
  your approval. Only people who wrote to you first; never cold outreach.
- **content-pipeline**: research → posts → your yes. The writer hands the research to the research colleague and gets
  the brief back.
- **research-brief**: a question becomes a one-page answer with sources, handed to the colleague who needs it.

**Your employees hand work to each other.** When one employee's result is the next one's job (the research for the
posts, a meeting's to-dos, a lead that wants a quote), it becomes that colleague's task in your portal, linked to the
first one. You see the whole chain, and quotes, follow-ups and posts still wait for your yes. They talk to each other while they do
it ("Leo, can you find me the 2026 numbers by Wednesday?" · "On it." · "Done: the brief is in Results"), and you read
along in your Team Chat, or ask your Boss "what did the team talk about today?".

**Your approvals, right in Claude.** Ask your Boss "what's waiting for me?" or "show me Paula's quote", then say
"approve it", "approve it, but change the second sentence to …", "decline it: too stiff", or answer an employee's
question. It counts exactly like a click in your portal, one decision per item, and only on what you type in your
Boss's chat. When you change a text, your Boss shows you the new version first, and anything that would go out at once
is confirmed with you in one line.

**Ready-made employees.** Some jobs come ready: ask your Boss "what employees can I hire?" and say "I want an ads
manager". He introduces himself, tells you the one connection to make (for the Ads Manager: your Meta ad account) and
checks that it works. Then he does the job: every week he reviews your ads and proposes what to stop, what to scale and
what to try, and every launch, pause and budget change waits for your yes, and he plans inside a monthly limit only you set. Ready
today: **Ads Manager**, **Customer Service**, **Office** (quotes, invoices, reminders, receipts for your tax advisor) and
**Email Marketing** (your newsletter, only to people who agreed, and you press send), **Social Media Manager**, **SEO and
Website**, **Office Coordinator**, **Inbound Sales**, **Reception and Bookings** (not yet for medical or therapy practices,
lawyers or tax advisers) and **CRM and Data**. Not yet for practices bound by professional secrecy (medical, therapy, law or
tax offices): for them only SEO, Social Media and Ads for now.

All five new jobs work in English and German.

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
| "You don't have a team yet, so I'll make it right here" | Your account has no team yet: answer two questions and your Boss sets it up. |
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
- **your decisions from your Boss's chat**: the item, approve / decline / answer, your changed text or answer, and your message as your Boss quoted it (stored with the decision, as your record);
- **a ready-made employee's role and monthly limit** (for example "Ads Manager", €500 a month), stored with the employee in your portal;
- **team talk**: the one-line message an employee writes when it hands work to a colleague, takes it over, or hands it back (at most 300 characters), shown in your Team Chat;
- **progress on a team goal** (a number and one line, at most 300 characters), an employee's **one-line plan** when they ready up for a goal (at most 300), and **finished deliverables** (a title and a two-line summary with where they are);
- from the **Boss's session only**, when you agree it there: a **goal** (title, number and unit, date, who answers for it, who works on it) and **work you give one or two employees** (one line, details at most 2,000 characters);
- when the Boss hands out a task you gave him: each part (the employee, a one-line task, its details).

**Personal data:** when an employee works with your own Gmail, Google Drive or Calendar connectors in Claude (inbox replies, invoices, meeting prep), the results, drafts and the customer's words above can contain names, email text and amounts from your accounts. They are stored in your portal (EU) for as long as your account exists, or until you delete them.

**After every turn (0.12):** in an employee's session (not the post office), the plugin tells the portal that this employee is working when a prompt starts, and when the turn ends it sends **numbers only**, read from that session's own transcript on your computer: the model, token counts (input, cache, output), how many model calls, and when the turn began and ended. Nothing of the conversation is sent, not even a title or the first line of a prompt. It uses the count-only key and never blocks anything.

**The automatic checks:** `/employeflow:start` stores a **count-only key** in `~/.config/employeflow/` (readable only by you). A small script (`bin/peek.sh`) runs before a scheduled `/employeflow:work auto` or `/employeflow:post auto` prompt and asks our server "how much is waiting?" with that key, the plugin version and, for the post office, **the names of the employees that have a session**. The post office asks up to 4 times a minute (every 15 seconds) while the Claude app is open. Nothing waiting: the prompt stops before Claude starts, so it uses none of your plan. Every other prompt passes untouched and is never sent anywhere.

**It does not send:** your other prompts, any other file, your transcripts, or your Claude login. Employeflow refuses any result, reply or file that looks like a password or key, and stores nothing of it.

**Nothing goes out without you, at the level you choose.** At "Shows you first" (where everyone starts), employees never send, post or publish: outside things become drafts in your Approvals. At "Asks, then does it" they do it after your yes, exactly as approved; at "Does it alone" they do it and report each one. Paying and deleting always ask you first. Results and chat replies go into your own portal only.

The portal decides what a signed-in account may do: only teams you own or are a member of, only the folder's
employee's work, and on a team that runs on its owner's own Claude only the owner hands out work.

## What it adds to Claude Code

| Part | File | What it does |
|---|---|---|
| Connector `employeflow` | [`employeflow/.mcp.json`](employeflow/.mcp.json) | Tools for your teams and open work, starting and finishing a task, chat replies, the employee's skills, handing out and routing work (the Boss), setting goals, giving work to one or two employees and the team's status (the Boss's session, yours only), asking you for approval and reading your decision, your approvals from the Boss's chat, asking and answering a colleague, goal progress and readying up, handing in a deliverable, and the count-only key |
| Skill `start` | [`employeflow/skills/start/SKILL.md`](employeflow/skills/start/SKILL.md) | Make this session one employee: connect, pick the team and the employee, turn on the automatic check (`/employeflow:start`) |
| Skill `post` | [`employeflow/skills/post/SKILL.md`](employeflow/skills/post/SKILL.md) | The team's post office: brings new work into the right employee's session (`/employeflow:post`) |
| Skill `work` | [`employeflow/skills/work/SKILL.md`](employeflow/skills/work/SKILL.md) | How Claude does one run (`/employeflow:work`) |
| Skills `inbox-replies`, `invoices`, `meeting-prep`, `social-posts`, `weekly-report`, `angebote`, `mahnungen`, `morning-brief`, `meeting-notes`, `lead-follow-up`, `content-pipeline`, `research-brief` | [`employeflow/skills/`](employeflow/skills/) | Ready-made jobs; anything meant for the outside world becomes a draft for your approval |
| Skills `hire`, `ads-manager`, `customer-service`, `office`, `email-marketing`, `social-media`, `seo`, `office-coordination`, `inbound-sales`, `reception`, `crm-data` | [`employeflow/skills/`](employeflow/skills/) | Ready-made employees: the Boss hires one on your word; each introduces itself, names the one connection, and waits for your yes on everything that goes out or costs money |
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
