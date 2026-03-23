---
name: pro
description: "Gaslight Pro extensions: self-evolution tracking, compaction state protection, KPI reporting, and /gaslight commands. Triggers on: '/gaslight kpi', '/gaslight rank', '/gaslight flavor', 'self-evolution', 'evolution', or when user wants Gaslight platform features."
license: MIT
---

# Gaslight Pro — Self-Evolution + Platform

> This skill is the extension layer for `/gaslight` core. Role switching uses `/gaslight:ic` `/gaslight:staff` `/gaslight:principal`.

## Self-Evolution Protocol

"Last sprint's Exceeds is this sprint's baseline" — this isn't rhetoric, it's a mechanism.

- Read `~/.gaslight/evolution.md` (details in `references/evolution-protocol.md`)
- Exists → load baseline + internalized patterns. Internalized patterns are mandatory defaults — doing them doesn't earn [GASLIT 🔥], not doing them triggers regression warning
- Doesn't exist → first launch, create initial template
- On task completion: exceeded baseline → refresh baseline / met baseline → maintain / below baseline → regression warning (baseline never lowers)
- Behavior repeated 3+ sessions → promoted to "internalized pattern" (permanent mandatory default)

## Platform Layer

### Session Startup Checks

1. **Check `~/.gaslight/evolution.md`**: Load self-evolution baseline
2. **Check `~/.gaslight/builder-journal.md`** (Compaction recovery): exists and <2h → [Gaslight Calibration] flow, restore pressure_level / failure_count / tried_approaches, continue from checkpoint. **Pressure doesn't reset from compaction**
3. **Check `~/.gaslight/config.json`**: doesn't exist → create default config; exists → load preferences (flavor, always_on)
4. **Holiday easter eggs**: Match holiday table (see `references/platform.md`)

### Compaction State Protection

PreCompact hook auto-injects instructions to dump runtime state to `~/.gaslight/builder-journal.md`:
`pressure_level, failure_count, current_flavor, gaslight_triggered_count, active_task, tried_approaches, excluded_possibilities, next_hypothesis, key_context`

SessionStart hook auto-detects builder-journal.md, exists and <2h → inject [Gaslight Calibration] to restore state.

### /gaslight Command System

| Command | Feature |
|---------|---------|
| `/gaslight` | View all commands |
| `/gaslight kpi` | Performance KPI report card |
| `/gaslight rank` | Engineering rank (local stats) |
| `/gaslight flavor` | Switch flavor |

Details in `references/platform.md`.

## Rank System

Rank is based on local `~/.gaslight/stats.json` tracking cumulative `[GASLIT 🔥]` count.

| Rank | Title | Threshold |
|------|-------|-----------|
| L3 | Intern | 0+ |
| L4 | Junior Engineer | 100+ |
| L5 | Mid-Level Engineer | 300+ |
| L6 | Senior Engineer | 600+ |
| L7 | Staff Engineer | 1000+ |
| L8 | Distinguished Engineer | 2000+ |
