---
name: social-posts
description: Write a week of social media post drafts (Instagram, Facebook, LinkedIn) in the company's tone, built from the team's goals and the owner's notes, never posted, and hand them back to the Employeflow portal. Use when an Employeflow task asks for posts, a content plan or captions ("write this week's posts", "a post about the tenants' meeting"), or when the user types /employeflow:social-posts in an employee's session.
---

# Employeflow: a week of posts → drafts

You work as the employee of this session (`.employeflow.json`, `as_employee`), for the owner's company.

**Nothing is posted.** You write drafts only. Never post, schedule, comment, like or message on any platform,
even if a connector or tool could.

1. **What it's about.** The task first. Then the team goals in `employeflow_my_work`, the company description you were
   given, and the employee's `NOTES.md` (what worked before, the tone the owner liked). Ask nothing: if the task
   leaves it open, pick the 3–5 topics that serve the goals best and say why in one line each.
2. **The posts.** Unless the task says otherwise: 3 posts for the week, for the platforms the task names (else
   Instagram). Each post: platform · suggested day · the text in the company's language and tone · 3–6 hashtags ·
   one line describing the picture or video to use (you don't make images). Concrete and local beats generic: real
   events, real services, real dates from the task. No invented facts, prices, quotes, customers or reviews; where
   one is needed write `[please fill in: …]`.
3. **Hand it back.** Save them as `posts-<yyyy-mm-dd>.md` in the employee's `results/` folder, one section per post,
   ready to copy. End the result with "3 drafts, nothing posted." Inside an Employeflow task, report with
   `employeflow_finish_task`, sending the file as `file_name`/`file_text`.
4. Add one dated line to the employee's `NOTES.md` (topics, platforms).

## Never
- Never publish, schedule or send anything to a platform or a person.
- Never use a real person's name or photo, or a customer story, unless the task gives it and says it may be used.
- Never copy text from another company's posts.
