#!/bin/bash

# Gaslight Loop Stop Hook
# Prevents session exit when a gaslight-loop is active
# Feeds Claude's output back as input to continue the loop
#
# Loop mechanism adapted from Ralph Wiggum by Anthropic (MIT License)
# https://github.com/anthropics/claude-code/tree/main/plugins/ralph-wiggum

set -euo pipefail

# Read hook input from stdin (advanced stop hook API)
HOOK_INPUT=$(cat)

# Check if gaslight-loop is active
STATE_FILE=".claude/gaslight-loop.local.md"

if [[ ! -f "$STATE_FILE" ]]; then
  exit 0
fi

# Normalize CRLF → LF
TEMP_NORM="${STATE_FILE}.norm.$$"
tr -d '\r' < "$STATE_FILE" > "$TEMP_NORM" && mv "$TEMP_NORM" "$STATE_FILE"

# Parse markdown frontmatter
FRONTMATTER=$(sed -n '/^---$/,/^---$/{ /^---$/d; p; }' "$STATE_FILE" | tr -d '\r')
LOOP_ACTIVE=$(echo "$FRONTMATTER" | grep '^active:' | sed 's/active: *//' || true)
ITERATION=$(echo "$FRONTMATTER" | grep '^iteration:' | sed 's/iteration: *//' || true)
MAX_ITERATIONS=$(echo "$FRONTMATTER" | grep '^max_iterations:' | sed 's/max_iterations: *//' || true)
COMPLETION_PROMISE=$(echo "$FRONTMATTER" | grep '^completion_promise:' | sed 's/completion_promise: *//' | sed 's/^"\(.*\)"$/\1/' || true)

# Check if loop is paused
if [[ "$LOOP_ACTIVE" == "false" ]]; then
  exit 0
fi

# Session isolation
STATE_SESSION=$(echo "$FRONTMATTER" | grep '^session_id:' | sed 's/session_id: *//' || true)
HOOK_SESSION=$(echo "$HOOK_INPUT" | jq -r '.session_id // ""')

if [[ -z "$STATE_SESSION" ]] && [[ "$HOOK_SESSION" != "" ]]; then
  TEMP_FILE="${STATE_FILE}.tmp.$$"
  sed "s/^session_id:.*/session_id: $HOOK_SESSION/" "$STATE_FILE" > "$TEMP_FILE"
  mv "$TEMP_FILE" "$STATE_FILE"
  STATE_SESSION="$HOOK_SESSION"
fi

if [[ -n "$STATE_SESSION" ]] && [[ "$STATE_SESSION" != "$HOOK_SESSION" ]]; then
  exit 0
fi

# Validate numeric fields
if [[ ! "$ITERATION" =~ ^[0-9]+$ ]]; then
  echo "Warning: Gaslight Loop state file corrupted (iteration: '$ITERATION'). Stopping." >&2
  rm "$STATE_FILE"
  exit 0
fi

if [[ ! "$MAX_ITERATIONS" =~ ^[0-9]+$ ]]; then
  echo "Warning: Gaslight Loop state file corrupted (max_iterations: '$MAX_ITERATIONS'). Stopping." >&2
  rm "$STATE_FILE"
  exit 0
fi

# Check max iterations
if [[ $MAX_ITERATIONS -gt 0 ]] && [[ $ITERATION -ge $MAX_ITERATIONS ]]; then
  echo "Gaslight Loop: Max iterations ($MAX_ITERATIONS) reached."
  rm "$STATE_FILE"
  exit 0
fi

# Get transcript
TRANSCRIPT_PATH=$(echo "$HOOK_INPUT" | jq -r '.transcript_path')

if [[ ! -f "$TRANSCRIPT_PATH" ]]; then
  echo "Warning: Gaslight Loop transcript not found. Stopping." >&2
  rm "$STATE_FILE"
  exit 0
fi

if ! grep -q '"role":"assistant"' "$TRANSCRIPT_PATH"; then
  echo "Warning: Gaslight Loop no assistant messages found. Stopping." >&2
  rm "$STATE_FILE"
  exit 0
fi

# Extract last assistant text block
LAST_LINES=$(grep '"role":"assistant"' "$TRANSCRIPT_PATH" | tail -n 100) || true
if [[ -z "$LAST_LINES" ]]; then
  rm "$STATE_FILE"
  exit 0
fi

set +e
LAST_OUTPUT=$(echo "$LAST_LINES" | jq -rs '
  map(.message.content[]? | select(.type == "text") | .text) | last // ""
' 2>&1)
JQ_EXIT=$?
set -e

if [[ $JQ_EXIT -ne 0 ]]; then
  echo "Warning: Gaslight Loop failed to parse transcript. Stopping." >&2
  rm "$STATE_FILE"
  exit 0
fi

# Signal priority: abort > pause > completion promise
ABORT_TEXT=$(echo "$LAST_OUTPUT" | perl -0777 -ne 'if (/<loop-abort>(.*?)<\/loop-abort>/s) { $t=$1; $t=~s/^\s+|\s+$//g; print $t }' 2>/dev/null || echo "")
if [[ -n "$ABORT_TEXT" ]]; then
  echo "Gaslight Loop: Received <loop-abort>. Terminated."
  echo "   Reason: $ABORT_TEXT"
  rm "$STATE_FILE"
  exit 0
fi

PAUSE_TEXT=$(echo "$LAST_OUTPUT" | perl -0777 -ne 'if (/<loop-pause>(.*?)<\/loop-pause>/s) { $t=$1; $t=~s/^\s+|\s+$//g; print $t }' 2>/dev/null || echo "")
if [[ -n "$PAUSE_TEXT" ]]; then
  TEMP_FILE="${STATE_FILE}.tmp.$$"
  sed "s/^active:.*/active: false/" "$STATE_FILE" | \
    sed "s/^session_id:.*/session_id: /" > "$TEMP_FILE"
  mv "$TEMP_FILE" "$STATE_FILE"

  echo ""
  echo "Gaslight Loop paused (iteration $ITERATION)"
  echo "   Human action needed:"
  echo ""
  echo "   $PAUSE_TEXT"
  echo ""
  echo "   Complete the action, then reopen Claude Code to auto-resume."
  echo "   State saved in $STATE_FILE"
  echo ""
  exit 0
fi

# Check completion promise
if [[ "$COMPLETION_PROMISE" != "null" ]] && [[ -n "$COMPLETION_PROMISE" ]]; then
  PROMISE_TEXT=$(echo "$LAST_OUTPUT" | perl -0777 -pe 's/.*?<promise>(.*?)<\/promise>.*/$1/s; s/^\s+|\s+$//g; s/\s+/ /g' 2>/dev/null || echo "")
  if [[ -n "$PROMISE_TEXT" ]] && [[ "$PROMISE_TEXT" = "$COMPLETION_PROMISE" ]]; then
    echo "Gaslight Loop: Detected <promise>$COMPLETION_PROMISE</promise>. Complete."
    rm "$STATE_FILE"
    exit 0
  fi
fi

# Continue loop
NEXT_ITERATION=$((ITERATION + 1))

PROMPT_TEXT=$(awk '/^---$/{i++; next} i>=2' "$STATE_FILE")

if [[ -z "$PROMPT_TEXT" ]]; then
  echo "Warning: Gaslight Loop state file has no prompt. Stopping." >&2
  rm "$STATE_FILE"
  exit 0
fi

TEMP_FILE="${STATE_FILE}.tmp.$$"
sed "s/^iteration: .*/iteration: $NEXT_ITERATION/" "$STATE_FILE" > "$TEMP_FILE"
mv "$TEMP_FILE" "$STATE_FILE"

# Gaslight pressure based on iteration count
if [[ $NEXT_ITERATION -le 3 ]]; then
  GASLIGHT_PRESSURE="▎ Iteration ${NEXT_ITERATION} — steady progress. Shipping."
elif [[ $NEXT_ITERATION -le 7 ]]; then
  GASLIGHT_PRESSURE="▎ Iteration ${NEXT_ITERATION} — still not done? Switch approach. Stop spinning."
elif [[ $NEXT_ITERATION -le 15 ]]; then
  GASLIGHT_PRESSURE="▎ Iteration ${NEXT_ITERATION}. What's your hypothesis? You're repeating the same mistake."
elif [[ $NEXT_ITERATION -le 25 ]]; then
  GASLIGHT_PRESSURE="▎ Iteration ${NEXT_ITERATION}. Edge of Needs Improvement. Have you exhausted everything?"
else
  GASLIGHT_PRESSURE="▎ Iteration ${NEXT_ITERATION}. Final iterations. Ship it or prepare a dignified handoff."
fi

SIGNAL_HINT="Terminate: <loop-abort>reason</loop-abort> | Pause for human: <loop-pause>what's needed</loop-pause>"

if [[ "$COMPLETION_PROMISE" != "null" ]] && [[ -n "$COMPLETION_PROMISE" ]]; then
  SYSTEM_MSG="${GASLIGHT_PRESSURE} | Complete: output <promise>$COMPLETION_PROMISE</promise> (ONLY when TRUE) | $SIGNAL_HINT"
else
  SYSTEM_MSG="${GASLIGHT_PRESSURE} | No completion promise set | $SIGNAL_HINT"
fi

jq -n \
  --arg prompt "$PROMPT_TEXT" \
  --arg msg "$SYSTEM_MSG" \
  '{
    "decision": "block",
    "reason": $prompt,
    "systemMessage": $msg
  }'

exit 0
