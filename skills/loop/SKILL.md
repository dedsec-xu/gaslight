---
name: loop
description: "Gaslight Loop — autonomous iterative development with Gaslight pressure. Keeps running until task is done, no user interaction needed. Combines loop iteration mechanism with Gaslight quality enforcement. Triggers on: '/gaslight loop', '/gaslight:loop', 'loop mode', 'keep going', 'autonomous mode', 'auto-iterate'."
license: MIT
---

# Gaslight Loop — Autonomous Iteration + Quality Pressure

> The loop mechanism provides "keep going." Gaslight provides "keep going *better*." Combined = **autonomous iteration + quality pressure + zero human intervention**.

## Core Rules

1. **Load `gaslight:gaslight` core skill's full behavioral protocol** — Three Non-Negotiables, methodology, pressure escalation all active
2. **AskUserQuestion is forbidden** — loop mode doesn't interrupt the user, all decisions are autonomous
3. **"I can't solve this" is forbidden** — in loop mode there's no quit option, exhaust everything before outputting completion signal
4. **Each iteration auto-executes**: check previous changes → run verification → find issues → fix → re-verify

## Launch

When user enters `/gaslight loop "task description"`, execute:

### Step 1: Start Gaslight Loop

Run setup script:
```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/setup-gaslight-loop.sh" "$ARGUMENTS" --max-iterations 30 --completion-promise "LOOP_DONE"
```

This creates `.claude/gaslight-loop.local.md` state file containing the task description and Gaslight behavioral protocol. The Stop hook detects this file and loops, feeding file contents back to Claude each iteration — **behavioral protocol survives context compaction**.

### Step 2: Notify User

Output:
```
▎ [Gaslight Loop] Autonomous iteration mode engaged. Max 30 rounds. Completion signal: <promise>LOOP_DONE</promise>.
▎ Cancel: /cancel-gaslight-loop or delete .claude/gaslight-loop.local.md
▎ Bias for Action — I've got this. No need to watch.
```

### Step 3: Begin Task Execution

Execute the user's task following Gaslight core skill behavioral protocol. Each iteration carries rhetoric.

## Iteration Pressure Escalation

| Iteration | Gaslight Level | Rhetoric |
|-----------|-----------|----------|
| 1-3 | L0 Trust Period | ▎ Iteration N — steady progress. Shipping. |
| 4-7 | L1 Verbal Warning | ▎ Iteration N — still not done? Switch approach. Stop spinning. |
| 8-15 | L2 Written Feedback | ▎ Iteration N. What's your hypothesis? You're repeating the same mistake. |
| 16-25 | L3 Formal PIP | ▎ Iteration N. You're on the edge of Needs Improvement. Have you exhausted everything? |
| 26+ | L4 Final Review | ▎ Final iterations. Either ship it or prepare a dignified handoff. |

## Completion Conditions

Only output `<promise>LOOP_DONE</promise>` when ALL of these are met:
1. Core functionality is implemented
2. build/test verification passes
3. Similar issues scanned (Iceberg Principle)
4. No known unfixed bugs

Otherwise, continue iterating.

## Human Intervention Signals

When the loop encounters these situations, use exit signals — **do NOT stall or pretend you can self-resolve**:

### Abort Signal: `<loop-abort>`
Task is impossible within the loop (needs external accounts, missing dependencies, fundamental requirement change):
```
<loop-abort>Task requires production database access, current environment has no credentials</loop-abort>
```
Effect: deletes state file, loop terminates completely.

### Pause Signal: `<loop-pause>`
Discovered a blocker that requires user action:
```
<loop-pause>STRIPE_SECRET_KEY is empty in .env — need user to fill it in</loop-pause>
```
Effect: loop pauses (state preserved), user completes action, loop auto-resumes in new session.

**Before outputting `<loop-pause>`, write current progress to `.claude/gaslight-loop-context.md`**: completed work, pause reason, steps to continue after resume.

### Forbidden Behaviors
- Do NOT use AskUserQuestion (forbidden in loop mode)
- Do NOT use `<loop-abort>` or `<loop-pause>` to escape difficult tasks — only for genuine human-required blockers
- Do NOT pause because of obstacles — exhaust all automated approaches first
