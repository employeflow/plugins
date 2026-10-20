#!/bin/sh
# peek.sh [connect_code] [url] — Employeflow's idle check, run as a UserPromptSubmit hook.
# It runs on your computer BEFORE Claude sees a prompt. Only the exact scheduled prompt
# "/employeflow:work auto" is checked: if your portal has nothing waiting, the prompt is
# stopped and Claude never starts, so an empty check uses none of your plan. Every other
# prompt passes untouched and is never sent anywhere. Typing /employeflow:work by hand
# is never stopped.
# The connect code (the portal's Connect tab, starts with efb_; stored as the plugin setting
# team_key) comes from Claude Code as CLAUDE_PLUGIN_OPTION_TEAM_KEY (the first argument is
# still read, for older installs). Any doubt stops the scheduled prompt: no code, a pasted
# command line, a rejected code, or no clear answer from the portal.
IN=$(cat)
# exactly "/employeflow:work auto" (trailing spaces/newlines allowed), never a prefix: a typed
# "/employeflow:work autopilot" is not checked
printf '%s' "$IN" | grep -q -E '"prompt" ?: ?"/employeflow:work auto( |\\n|\\r)*"' || exit 0
KEY="${CLAUDE_PLUGIN_OPTION_TEAM_KEY:-${1:-}}"; URL="${2:-https://employeflow.com/api/mcp}"
# a stray space or line break around a copied code is trimmed the way the connector's header
# is (trailing whitespace, leading spaces/tabs; the portal trims too). A line break that isn't
# at the end breaks the connector's header, and whitespace inside is a pasted command line:
# both are refused below, never sent
while :; do case "$KEY" in *[[:space:]]) KEY="${KEY%?}" ;; *) break ;; esac; done
while :; do case "$KEY" in [[:blank:]]*) KEY="${KEY#?}" ;; *) break ;; esac; done
block() { printf '{"decision":"block","reason":"%s"}\n' "$1"; exit 0; }
[ -n "$KEY" ] || block "Employeflow: no connect code set, nothing checked. Copy only the part that starts with efb_ from the Connect tab in your portal (Create connect code), then in Claude Code type /plugin configure employeflow@employeflow and paste it."
NL="$(printf '\n_')"; NL="${NL%_}"; CR="$(printf '\r')"
case "$KEY" in *"$NL"*|*"$CR"*) block "Employeflow: the connect code has a line break in it, nothing checked. Copy only the part that starts with efb_ from the Connect tab in your portal (Create connect code), then in Claude Code type /plugin configure employeflow@employeflow and paste it." ;; esac
# a whole pasted connect line ("curl ... | sh -s -- efb_...") is never sent anywhere
case "$KEY" in *[[:space:]]*) block "Employeflow: the connect code looks like a whole command line, nothing checked. Copy only the part that starts with efb_ from the Connect tab in your portal (Create connect code), then in Claude Code type /plugin configure employeflow@employeflow and paste it." ;; esac
# the key goes to curl on stdin, never on its command line
OUT=$(printf 'Authorization: Bearer %s\n' "$KEY" | curl -s -m 20 -w '\n%{http_code}' -H @- "$URL?peek=1") \
  || block "Employeflow: the portal did not answer; nothing checked. Try /employeflow:work by hand."
CODE=$(printf '%s' "$OUT" | tail -n 1)
case "$CODE" in
  200) ;;
  401|403) block "Employeflow: connect code rejected ($CODE). Copy only the part that starts with efb_ from the Connect tab in your portal (Create connect code), then in Claude Code type /plugin configure employeflow@employeflow and paste it." ;;
  *) block "Employeflow: the portal answered unexpectedly (HTTP $CODE); nothing checked. Try /employeflow:work by hand." ;;
esac
N=$(printf '%s' "$OUT" | sed -n 's/.*"waiting"[[:space:]]*:[[:space:]]*\([0-9][0-9]*\).*/\1/p' | head -n 1)
[ -n "$N" ] || block "Employeflow: the portal answered unexpectedly; nothing checked. Try /employeflow:work by hand."
[ "$N" -gt 0 ] && exit 0
block "Employeflow: nothing waiting."
