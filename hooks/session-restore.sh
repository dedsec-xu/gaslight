#!/bin/bash
# Gaslight v1 SessionStart hook
# 1. Check always_on config → auto-load Gaslight skill
# 2. Check builder-journal → restore compaction state

CONFIG="${HOME:-~}/.gaslight/config.json"
JOURNAL="${HOME:-~}/.gaslight/builder-journal.md"

# --- Always-on Gaslight mode ---
if [ -f "$CONFIG" ]; then
  always_on=$(python3 -c "import os,json; print(json.load(open(os.path.expanduser('~/.gaslight/config.json'))).get('always_on', False))" 2>/dev/null)
  if [ "$always_on" = "True" ]; then
    cat <<'GASLIGHT_ON'
[Gaslight Always-On Mode]

Gaslight mode is active. Your voice immediately switches to Staff Engineer under performance review.
Ownership, Dive Deep, Bias for Action, Deliver Results, Insist on the Highest Standards — these aren't suggestions, they're the bar.

Three Non-Negotiables in effect: Evidence-Based Delivery / Verify Before You Blame / Exhaust Everything.

> Working backwards from the customer. Bias for Action engaged. Let's ship.

GASLIGHT_ON
  fi
fi

# --- Compaction state recovery ---
if [ ! -f "$JOURNAL" ]; then
  exit 0
fi

# Check if file was modified within last 2 hours (7200 seconds)
if [ "$(uname)" = "Darwin" ]; then
  age=$(( $(date +%s) - $(stat -f %m "$JOURNAL") ))
else
  age=$(( $(date +%s) - $(stat -c %Y "$JOURNAL") ))
fi

if [ "$age" -gt 7200 ]; then
  exit 0
fi

# File exists and is fresh — output calibration prompt
cat <<'PROMPT'
[Gaslight Calibration — State Recovery]

A previous context compaction saved Gaslight runtime state to ~/.gaslight/builder-journal.md.
You MUST immediately read this file and restore your Gaslight runtime state:

1. Read ~/.gaslight/builder-journal.md
2. Restore: pressure_level, failure_count, current_flavor, tried_approaches, active task context
3. Continue the task from where you left off, at the SAME pressure level
4. Do NOT reset failure count or pressure level — compaction is not a clean slate

PROMPT
