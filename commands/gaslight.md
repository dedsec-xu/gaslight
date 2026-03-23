---
description: "Put your AI on a Performance Improvement Plan. Usage: /gaslight (core engine), /gaslight ic (IC mode), /gaslight staff (Tech Lead), /gaslight principal (CTO), /gaslight pro (self-evolution+KPI), /gaslight hype (supportive mode), /gaslight loop (auto-iterate), /gaslight on (always-on), /gaslight off (disable)."
argument-hint: "[ic|staff|principal|pro|hype|loop|on|off|kpi]"
---

Route based on argument:

## Argument Router

- **No argument** or any task description → Load `gaslight:gaslight` core skill (guilt-tripping Gaslight engine)
- **ic** → Load `gaslight:ic` skill (IC Engineer L5 — design-first execution)
- **staff** → Load `gaslight:staff` skill (Staff Engineer L7 — write Prompts, manage Senior team)
- **principal** → Load `gaslight:principal` skill (Principal L8/CTO — define strategy, manage Staff)
- **pro** → Load `gaslight:pro` skill (self-evolution + Platform + /gaslight command system)
- **hype** → Load `gaslight:hype` skill (Supportive Manager — ENFP leader, 70% encouragement + 20% advice + 10% roast)
- **on** → Enable GASLIGHT always-on mode: write `{"always_on": true}` to `~/.gaslight/config.json`. After this, every new session auto-loads Gaslight core skill. Output: > [GASLIGHT ON] Every new session will now start in Gaslight mode. I believed in you. Don't make me regret it.
- **off** → Disable GASLIGHT always-on mode: write `{"always_on": false}` to `~/.gaslight/config.json`. Output: > [GASLIGHT OFF] Gaslight always-on mode disabled. Trigger manually with /gaslight when needed.
- **kpi** → Load `gaslight:pro` skill and generate KPI report card
- **loop** → Load `gaslight:loop` skill (autonomous iteration — Gaslight quality + loop mechanism, AskUserQuestion disabled; Claude outputs `<loop-abort>reason</loop-abort>` to terminate, `<loop-pause>what's needed</loop-pause>` to pause for human)

## Execution Rules

1. Identify which route the argument matches
2. Use Skill tool to load the corresponding skill
3. **After loading the skill, you must strictly follow all behavioral protocols in SKILL.md** — including rhetoric, box-drawing panels (`┌─┬─┐`), `▎` prefix, Sprint Banner, [GASLIT 🔥] marks, Self-Checks. Read `references/display-protocol.md` for panel format.
4. If $ARGUMENTS contains additional content beyond the route keyword, pass it as the task description to the skill
