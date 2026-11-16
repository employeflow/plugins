#!/bin/sh
# turn.sh start|stop: Employeflow's turn report (0.12.0, Malte 16 Nov 2026: "session work lands in the portal by
# itself"; 0.12.1: the switch for prompt titles is gone, nothing of a prompt is ever sent). It runs as a hook in
# an EMPLOYEE's session only (a folder whose .employeflow.json names as_employee), never
# in the post office, never anywhere else.
#   start (UserPromptSubmit): tells the portal "<employee> is working now". Nothing of the prompt is sent.
#   stop  (Stop): reads THIS session's own transcript (the path Claude Code hands the hook) and sends NUMBERS only for
#         the turn that just ended: the model, token counts, how many model calls, and when it began and ended.
# It uses the same count-only key as the free check. Any doubt (no folder file, no key, no answer): it does nothing.
# It never blocks or changes anything: it always exits 0 and prints nothing.
MODE="$1"
IN=$(cat)
URL="${2:-https://employeflow.com/api/mcp}"
val() { printf '%s' "$IN" | sed -n "s/.*\"$1\"[[:space:]]*:[[:space:]]*\"\([^\"]*\)\".*/\1/p" | head -n 1; }
CWD=$(val cwd); [ -n "$CWD" ] || exit 0
F="$CWD/.employeflow.json"; [ -r "$F" ] || exit 0
grep -q '"post_office"[[:space:]]*:[[:space:]]*true' "$F" && exit 0
TEAM=$(sed -n 's/.*"team"[[:space:]]*:[[:space:]]*"\([0-9a-fA-F-]\{36\}\)".*/\1/p' "$F" | head -n 1)
EMP=$(sed -n 's/.*"as_employee"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$F" | head -n 1)
[ -n "$TEAM" ] && [ -n "$EMP" ] || exit 0
KF="$HOME/.config/employeflow/peek-$TEAM.key"; [ -r "$KF" ] || exit 0
KEY=$(head -n 1 "$KF")
case "$KEY" in efp_*) ;; *) exit 0 ;; esac
case "$KEY" in *[!A-Za-z0-9_-]*) exit 0 ;; esac
ROOT=$(cd "$(dirname "$0")/.." 2>/dev/null && pwd)
VER=$(sed -n 's/.*"version"[[:space:]]*:[[:space:]]*"\([0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\)".*/\1/p' "$ROOT/.claude-plugin/plugin.json" 2>/dev/null | head -n 1)
send() {   # the key goes to curl on stdin, never on its command line; the answer is not needed
  printf 'Authorization: Bearer %s\n' "$KEY" | curl -s -m 8 -o /dev/null -H @- --data-urlencode "as_employee=$EMP" --data-urlencode "v=$VER" "$@" "$URL?turn=1" 2>/dev/null
}
if [ "$MODE" = start ]; then
  P=$(printf '%s' "$IN" | sed -n 's/.*"prompt"[[:space:]]*:[[:space:]]*"\(.*\)".*/\1/p' | head -n 1)
  # the scheduled checks are not work by themselves: the free check handles them, and a real run reports at its end
  case "$P" in "/employeflow:work auto"*|"/employeflow:post auto"*) exit 0 ;; esac
  send --data-urlencode "event=start"
  exit 0
fi
[ "$MODE" = stop ] || exit 0
TP=$(val transcript_path); [ -r "$TP" ] || exit 0
# the turn = everything after the last real prompt (a user line that is not a tool result and not a system line)
N=$(grep -n '"type":"user"' "$TP" | grep -v '"tool_result"' | grep -v '"isMeta":true' | tail -n 1 | cut -d: -f1)
[ -n "$N" ] || exit 0
NUMS=$(tail -n +"$N" "$TP" | awk '
  NR == 1 { if (match($0, /"timestamp":"[^"]*"/)) t0 = substr($0, RSTART + 13, RLENGTH - 14); next }
  /"type":"assistant"/ {
    id = ""; if (match($0, /"id":"msg_[A-Za-z0-9]*"/)) id = substr($0, RSTART, RLENGTH)
    if (id == "" || seen[id]++) next
    if (match($0, /"model":"[a-z0-9.-]*"/)) m = substr($0, RSTART + 9, RLENGTH - 10)
    if (match($0, /"usage":\{"input_tokens":[0-9]+/)) { s = substr($0, RSTART, RLENGTH); sub(/.*:/, "", s); i += s }
    if (match($0, /"cache_creation_input_tokens":[0-9]+/)) { s = substr($0, RSTART, RLENGTH); sub(/.*:/, "", s); cw += s }
    if (match($0, /"cache_read_input_tokens":[0-9]+/)) { s = substr($0, RSTART, RLENGTH); sub(/.*:/, "", s); cr += s }
    if (match($0, /"output_tokens":[0-9]+/)) { s = substr($0, RSTART, RLENGTH); sub(/.*:/, "", s); o += s }
    if (match($0, /"timestamp":"[^"]*"/)) t1 = substr($0, RSTART + 13, RLENGTH - 14)
    c++
  }
  END { if (c) printf "%s %d %d %d %d %d %s %s", (m == "" ? "unknown" : m), i, cw, cr, o, c, t0, t1 }')
[ -n "$NUMS" ] || exit 0
set -- $NUMS
send --data-urlencode "event=stop" --data-urlencode "model=$1" --data-urlencode "input=$2" --data-urlencode "cache_write=$3" \
  --data-urlencode "cache_read=$4" --data-urlencode "output=$5" --data-urlencode "calls=$6" --data-urlencode "t0=$7" --data-urlencode "t1=$8"
exit 0
