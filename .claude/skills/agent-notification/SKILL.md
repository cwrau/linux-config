---
name: agent-notification
description: Push a notification to the user's phone via the `agent-notification` script — use when you have a blocking question, hit an error needing their input, or finish something that needs their attention while they're away.
---

Run `agent-notification [-t TITLE] MESSAGE` to push a notification to cwr's phone (via Pushbullet). Available in `PATH` on every session — Claude Code or otherwise, doesn't matter which project.

Use it for:
- A blocking question and the user may not be watching the session
- An error or problem that needs their decision before you can continue
- A long-running task finishing while they were likely away

Don't use it for routine progress updates, or anything they're clearly already watching — same judgement as any other push notification.

Keep `MESSAGE` short (one or two lines) — it's a mobile push, not a report. If run inside an Agent of Empires session (`AOE_ARTIFACT_DIR` set), the script appends a link back to that chat automatically — don't build that link yourself.

Example:

```
agent-notification -t "Needs your input" "Which auth flow -- OAuth or API key?"
```
