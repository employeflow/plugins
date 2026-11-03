#!/bin/sh
# push.sh — Employeflow's channel PROOF (3 Nov 2026, Malte: "go channels"). NOT shipped in the plugin.
#
# A Claude Code "channel" is a local MCP server that pushes messages into a running session
# (notifications/claude/channel). During Anthropic's research preview only approved channel plugins may push; anything
# else needs `claude --dangerously-load-development-channels server:employeflow-push`, started by hand in a terminal,
# with a warning screen. This file proves the path on Malte's Mac before we ask Anthropic to list Employeflow.
#
# Plain sh + curl, so nothing has to be installed. It answers the few MCP requests Claude Code sends (initialize,
# ping, tools/list) and, every EF_PUSH_EVERY seconds (default 5), asks the portal with the team's check key how much is
# waiting for THIS folder's employee (counts only: the key never reads a task or a message). When something new is
# waiting it pushes one line into the session; the session then fetches the work itself with its own sign-in
# (/employeflow:work). A check that finds nothing costs no Claude turn.
URL="${EF_URL:-https://employeflow.com/api/mcp}"
EVERY="${EF_PUSH_EVERY:-5}"
DIR="${EF_DIR:-$(pwd)}"
TEAM=$(sed -n 's/.*"team"[[:space:]]*:[[:space:]]*"\([0-9a-fA-F-]\{36\}\)".*/\1/p' "$DIR/.employeflow.json" 2>/dev/null | head -n 1)
EMP=$(sed -n 's/.*"as_employee"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$DIR/.employeflow.json" 2>/dev/null | head -n 1)
KF="$HOME/.config/employeflow/peek-$TEAM.key"
log() { printf '%s\n' "$*" >&2; }
# a JSON string from plain text: backslash, quote and control characters escaped
js() { printf '%s' "$1" | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g' | tr -d '\000-\037'; }

poll() {
  [ -n "$TEAM" ] && [ -n "$EMP" ] && [ -r "$KF" ] || { log "employeflow-push: no employee folder or no check key here; nothing to push"; return; }
  KEY=$(head -n 1 "$KF"); case "$KEY" in efp_*) ;; *) log "employeflow-push: the check key looks wrong"; return ;; esac
  LAST=0; LAST_AT=0
  while :; do
    OUT=$(printf 'Authorization: Bearer %s\n' "$KEY" | curl -s -m 10 -G -H @- --data-urlencode "as_employee=$EMP" "$URL?peek=1" 2>/dev/null)
    N=$(printf '%s' "$OUT" | sed -n 's/.*"waiting"[[:space:]]*:[[:space:]]*\([0-9][0-9]*\).*/\1/p' | head -n 1)
    NOW=$(date +%s)
    if [ -n "$N" ] && [ "$N" -gt 0 ]; then
      # new work, or still waiting 10 minutes after the last push (the session was busy or closed)
      if [ "$N" -gt "$LAST" ] || [ $((NOW - LAST_AT)) -ge 600 ]; then
        T=$(js "New in your Employeflow portal for $EMP: $N waiting (tasks or messages). Do them now: same steps as /employeflow:work (this session is $EMP).")
        printf '{"jsonrpc":"2.0","method":"notifications/claude/channel","params":{"content":"%s","meta":{"employee":"%s","waiting":"%s"}}}\n' "$T" "$(js "$EMP")" "$N"
        LAST_AT=$NOW
      fi
    fi
    [ -n "$N" ] && LAST=$N
    sleep "$EVERY"
  done
}

poll &
PP=$!
# Claude Code stops the server by closing stdin (the loop below ends) or by a signal: the poller goes with it
trap 'kill $PP 2>/dev/null' EXIT
trap 'kill $PP 2>/dev/null; exit 0' INT TERM HUP
# the MCP side: answer by request id (numbers or strings), ignore notifications
while IFS= read -r LINE; do
  ID=$(printf '%s' "$LINE" | sed -E -n 's/.*"id"[[:space:]]*:[[:space:]]*("[^"]*"|[0-9]+).*/\1/p' | head -n 1)
  M=$(printf '%s' "$LINE" | sed -n 's/.*"method"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -n 1)
  [ -n "$ID" ] || continue
  case "$M" in
    initialize)
      PV=$(printf '%s' "$LINE" | sed -n 's/.*"protocolVersion"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -n 1)
      printf '{"jsonrpc":"2.0","id":%s,"result":{"protocolVersion":"%s","capabilities":{"experimental":{"claude/channel":{}}},"serverInfo":{"name":"employeflow-push","version":"0.1.0"},"instructions":"Events from Employeflow arrive as <channel source=\\"employeflow-push\\" employee=\\"...\\" waiting=\\"...\\">. They mean new work for this employee is waiting in the owner'"'"'s portal: do it right away with the steps of /employeflow:work. They carry no task text; fetch the work with employeflow_my_work."}}\n' "$ID" "${PV:-2025-06-18}" ;;
    ping) printf '{"jsonrpc":"2.0","id":%s,"result":{}}\n' "$ID" ;;
    tools/list) printf '{"jsonrpc":"2.0","id":%s,"result":{"tools":[]}}\n' "$ID" ;;
    *) printf '{"jsonrpc":"2.0","id":%s,"error":{"code":-32601,"message":"method not found"}}\n' "$ID" ;;
  esac
done
