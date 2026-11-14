#!/bin/sh
# peek.sh [connect_code] [url] — Employeflow's idle check, run as a UserPromptSubmit hook.
# It runs on your computer BEFORE Claude sees a prompt. Only the exact scheduled prompt
# "/employeflow:work auto" is checked: if your portal has nothing waiting, the prompt is
# stopped and Claude never starts, so an empty check uses none of your plan. Every other
# prompt passes untouched and is never sent anywhere. Typing /employeflow:work by hand
# is never stopped.
# It uses only the count-only key /employeflow:start stored for this folder's team
# (~/.config/employeflow/peek-<team>.key, efp_...). No key, or any doubt (no clear answer
# from the portal), and the prompt simply goes ahead: Claude does the check itself.
# 0.10.1: the old 0.1 connect-code path (efb_, read from the plugin setting team_key) is gone;
# sign-in replaced it in 0.2 and the plugin declares no settings.
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
CWD=$(printf '%s' "$IN" | sed -n 's/.*"cwd"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -n 1)
[ -n "$CWD" ] || CWD=$(pwd)
TEAM=$(sed -n 's/.*"team"[[:space:]]*:[[:space:]]*"\([0-9a-fA-F-]\{36\}\)".*/\1/p' "$CWD/.employeflow.json" 2>/dev/null | head -n 1)
KF=""; [ -n "$TEAM" ] && KF="$HOME/.config/employeflow/peek-$TEAM.key"
{
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
}
