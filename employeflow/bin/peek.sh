#!/bin/sh
# peek.sh <team_key> [url] — Employeflow's zero-turn idle check (Jayden, 14 Oct 2026).
# A UserPromptSubmit hook: it runs BEFORE the model sees a prompt. Only the scheduled
# prompt "/employeflow:work auto" is gated: if the portal has nothing waiting, the prompt
# is blocked and the model never runs (measured: 0 turns, $0). Every other prompt passes
# untouched, without a network call. Typing /employeflow:work by hand is never blocked.
IN=$(cat)
# exactly "/employeflow:work auto" (trailing spaces/newlines allowed), never a prefix: a typed
# "/employeflow:work autopilot" must not be gated (Elliot's gate L3, 14 Oct)
printf '%s' "$IN" | grep -q -E '"prompt" ?: ?"/employeflow:work auto( |\\n|\\r)*"' || exit 0
KEY="$1"; URL="${2:-https://employeflow.com/api/mcp}"
block() { printf '{"decision":"block","reason":"%s"}\n' "$1"; exit 0; }
[ -n "$KEY" ] || block "Employeflow: no team key yet. Run /plugin configure employeflow@employeflow."
# the key goes to curl on stdin, never on its command line
OUT=$(printf 'Authorization: Bearer %s\n' "$KEY" | curl -s -m 20 -H @- "$URL?peek=1") \
  || block "Employeflow: the portal did not answer; nothing checked. Try /employeflow:work by hand."
N=$(printf '%s' "$OUT" | sed -n 's/.*"waiting":\([0-9][0-9]*\).*/\1/p')
[ -n "$N" ] || block "Employeflow: the portal answered unexpectedly; nothing checked. Try /employeflow:work by hand."
[ "$N" -gt 0 ] && exit 0
block "Employeflow: nothing waiting."
