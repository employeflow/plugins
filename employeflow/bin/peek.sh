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
# 0.5.0: the team's post office runs "/employeflow:post auto" every minute; the same free check, for its employees
POST=0
if printf '%s' "$IN" | grep -q -E '"prompt" ?: ?"/employeflow:post auto( |\\n|\\r)*"'; then POST=1
else printf '%s' "$IN" | grep -q -E '"prompt" ?: ?"/employeflow:work auto( |\\n|\\r)*"' || exit 0; fi
URL="${2:-https://employeflow.com/api/mcp}"
# this plugin's version, sent with the check so the portal can say when a newer one exists (0.3.1); the Claude app never
# fetches a newer Employeflow plugin by itself
ROOT=$(cd "$(dirname "$0")/.." 2>/dev/null && pwd)
VER=$(sed -n 's/.*"version"[[:space:]]*:[[:space:]]*"\([0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\)".*/\1/p' "$ROOT/.claude-plugin/plugin.json" 2>/dev/null | head -n 1)
QS="peek=1"; [ -n "$VER" ] && QS="peek=1&v=$VER"
# nothing waiting: stop the run, and say it if a newer plugin is ready (the steps come from the portal's answer)
idle() {
  case "$1" in *'"update":true'*)
    block "Employeflow: nothing waiting. A newer Employeflow plugin is ready: open a Code session, type /employeflow:work and say yes when Claude offers the update, then restart the Claude app." ;;
  esac
  block "Employeflow: all quiet, nothing new. (This is the free check; nothing is wrong.)"
}
# 0.7.1: the app shows every stopped prompt; there is no silent stop (hooks docs, 3 Nov 2026). suppressOriginalPrompt at
# least leaves out the "Original prompt: /employeflow:… auto" line under each one.
block() { printf '{"decision":"block","reason":"%s","hookSpecificOutput":{"hookEventName":"UserPromptSubmit","suppressOriginalPrompt":true}}\n' "$1"; exit 0; }
# SIGN-IN (0.2.0/0.3.0): the account's sign-in lives in Claude Code's own secure storage, which this hook cannot (and
# must not) read. /employeflow:start leaves a PEEK KEY instead: it can only count one team's waiting work. The team is
# the one in this folder's .employeflow.json; its key is ~/.config/employeflow/peek-<team>.key. Here any doubt (no
# file, no key, a refused key, no clear answer) lets the prompt PASS, so the work still runs and only costs a turn.
# 0.4.0 (measured 3 Nov 2026): a folder with its own check key wins over an old connect code. An install that once had a
# 0.1 connect code still hands it to this hook; when that code is no longer valid, every scheduled check was stopped
# with "connect code rejected" even with work waiting.
CWD=$(printf '%s' "$IN" | sed -n 's/.*"cwd"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -n 1)
[ -n "$CWD" ] || CWD=$(pwd)
TEAM=$(sed -n 's/.*"team"[[:space:]]*:[[:space:]]*"\([0-9a-fA-F-]\{36\}\)".*/\1/p' "$CWD/.employeflow.json" 2>/dev/null | head -n 1)
KF=""; [ -n "$TEAM" ] && KF="$HOME/.config/employeflow/peek-$TEAM.key"
if [ -z "${CLAUDE_PLUGIN_OPTION_TEAM_KEY:-${1:-}}" ] || { [ -n "$KF" ] && [ -r "$KF" ]; }; then
  [ -n "$TEAM" ] || exit 0
  [ -r "$KF" ] || exit 0
  KEY=$(head -n 1 "$KF")
  case "$KEY" in efp_*) ;; *) exit 0 ;; esac
  case "$KEY" in *[!A-Za-z0-9_-]*) exit 0 ;; esac
  # ONE SESSION = ONE EMPLOYEE (0.4.0): a folder made by /employeflow:start names its employee; then only that
  # employee's waiting work counts (sent url-encoded by curl, never built by hand)
  EMP=$(sed -n 's/.*"as_employee"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$CWD/.employeflow.json" 2>/dev/null | head -n 1)
  if [ "$POST" = 1 ]; then
    # the post office: the employees that have their own session, one name per line (the post office writes the file);
    # no file or no name yet: let the run go ahead, it writes the file
    SF="$HOME/.config/employeflow/seats-$TEAM.txt"
    [ -r "$SF" ] || exit 0
    # once an hour the run goes ahead anyway, so the post office rewrites the seats file from the app's sessions and a
    # closed or archived employee session stops looking connected (Elliot, 3 Nov: the empty minutes never refresh it)
    [ -n "$(find "$SF" -mmin +60 2>/dev/null)" ] && exit 0
    set --
    while IFS= read -r N || [ -n "$N" ]; do [ -n "$N" ] && set -- "$@" --data-urlencode "as_employee=$N"; done < "$SF"
    # no employee session yet (the post office wrote an empty file): nothing to deliver, free; the hourly run looks again
    [ "$#" -gt 0 ] || block "Employeflow post office: no employee sessions yet."
    # 0.6.1 (Malte 3 Nov: "every 15 seconds, and it can't cost anything"): the schedule can't fire more often than once
    # a minute, so within that minute this check looks up to 4 times, 15 seconds apart, and lets the post office run
    # the moment something is waiting. Nothing waiting: still stopped before Claude starts (free). It stops looking
    # after about 45 seconds so the next minute's run is never missed (the hook may run up to 58 seconds).
    EVERY="${EF_POST_EVERY:-15}"; T0=$(date +%s); I=0
    while :; do
      I=$((I + 1))
      OUT=$(printf 'Authorization: Bearer %s\n' "$KEY" | curl -s -m 10 -G -w '\n%{http_code}' -H @- "$@" "$URL?$QS&route=1") || exit 0
      [ "$(printf '%s' "$OUT" | tail -n 1)" = 200 ] || exit 0
      N=$(printf '%s' "$OUT" | sed -n 's/.*"waiting"[[:space:]]*:[[:space:]]*\([0-9][0-9]*\).*/\1/p' | head -n 1)
      [ -n "$N" ] || exit 0
      [ "$N" -gt 0 ] && exit 0
      [ "$I" -ge 4 ] && break
      [ $(( $(date +%s) - T0 + EVERY )) -le 45 ] || break
      sleep "$EVERY"
    done
    idle "$OUT"
  elif [ -n "$EMP" ]; then
    OUT=$(printf 'Authorization: Bearer %s\n' "$KEY" | curl -s -m 20 -G -w '\n%{http_code}' -H @- --data-urlencode "as_employee=$EMP" "$URL?$QS") || exit 0
  else
    OUT=$(printf 'Authorization: Bearer %s\n' "$KEY" | curl -s -m 20 -w '\n%{http_code}' -H @- "$URL?$QS") || exit 0
  fi
  [ "$(printf '%s' "$OUT" | tail -n 1)" = 200 ] || exit 0
  N=$(printf '%s' "$OUT" | sed -n 's/.*"waiting"[[:space:]]*:[[:space:]]*\([0-9][0-9]*\).*/\1/p' | head -n 1)
  [ -n "$N" ] || exit 0
  [ "$N" -gt 0 ] && exit 0
  idle "$OUT"
fi
KEY="${CLAUDE_PLUGIN_OPTION_TEAM_KEY:-${1:-}}"
# a stray space or line break around a copied code is trimmed the way the connector's header
# is (trailing whitespace, leading spaces/tabs; the portal trims too). A line break that isn't
# at the end breaks the connector's header, and whitespace inside is a pasted command line:
# both are refused below, never sent
while :; do case "$KEY" in *[[:space:]]) KEY="${KEY%?}" ;; *) break ;; esac; done
while :; do case "$KEY" in [[:blank:]]*) KEY="${KEY#?}" ;; *) break ;; esac; done
NL="$(printf '\n_')"; NL="${NL%_}"; CR="$(printf '\r')"
case "$KEY" in *"$NL"*|*"$CR"*) block "Employeflow: the connect code has a line break in it, nothing checked. Copy only the part that starts with efb_ from the Connect tab in your portal (Create connect code), then paste it in the Claude app under Settings → Plugins → Employeflow → Settings tab, or type /plugin configure employeflow@employeflow, then start a new session." ;; esac
# a whole pasted connect line ("curl ... | sh -s -- efb_...") is never sent anywhere
case "$KEY" in *[[:space:]]*) block "Employeflow: the connect code looks like a whole command line, nothing checked. Copy only the part that starts with efb_ from the Connect tab in your portal (Create connect code), then paste it in the Claude app under Settings → Plugins → Employeflow → Settings tab, or type /plugin configure employeflow@employeflow, then start a new session." ;; esac
# the key goes to curl on stdin, never on its command line
OUT=$(printf 'Authorization: Bearer %s\n' "$KEY" | curl -s -m 20 -w '\n%{http_code}' -H @- "$URL?$QS") \
  || block "Employeflow: the portal did not answer; nothing checked. Try /employeflow:work by hand."
CODE=$(printf '%s' "$OUT" | tail -n 1)
case "$CODE" in
  200) ;;
  401|403) block "Employeflow: connect code rejected ($CODE). Copy only the part that starts with efb_ from the Connect tab in your portal (Create connect code), then paste it in the Claude app under Settings → Plugins → Employeflow → Settings tab, or type /plugin configure employeflow@employeflow, then start a new session." ;;
  *) block "Employeflow: the portal answered unexpectedly (HTTP $CODE); nothing checked. Try /employeflow:work by hand." ;;
esac
N=$(printf '%s' "$OUT" | sed -n 's/.*"waiting"[[:space:]]*:[[:space:]]*\([0-9][0-9]*\).*/\1/p' | head -n 1)
[ -n "$N" ] || block "Employeflow: the portal answered unexpectedly; nothing checked. Try /employeflow:work by hand."
[ "$N" -gt 0 ] && exit 0
idle "$OUT"
