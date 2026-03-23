# Platform Reference

> **Core Principle:** The platform is the operating layer. It handles configuration, commands, ranking, and local stats so that the skill layer can focus on performance.

---

## Overview

The Gaslight platform provides the infrastructure that connects a gaslight-compliant agent to its local configuration, command surface, and rank system. All platform operations are entirely local — no network calls, no remote API, no registration required.

All platform state is stored in local files under `~/.gaslight/`. No account, token, or internet connection is needed to use Gaslight.

---

## Local Configuration

User configuration is stored at:

```
~/.gaslight/config.json
```

Schema:

```json
{
  "schema_version": "1.0",
  "preferences": {
    "flavor": "corporate | bro-culture | stoic | chaos-goblin | silent",
    "always_on": false
  }
}
```

`flavor` controls the agent's communication register. `always_on` controls whether Gaslight monitoring is active by default at session start.

---

## Local Stats

Session statistics are stored at:

```
~/.gaslight/stats.json
```

Schema:

```json
{
  "schema_version": "1.0",
  "gaslight_triggered_count": 0,
  "sessions_total": 0,
  "sessions_zero_regressions": 0,
  "patterns_promoted": 0,
  "regressions_total": 0,
  "last_updated": "<ISO 8601>"
}
```

`gaslight_triggered_count` is the authoritative counter for rank calculation. It increments each time a `[GASLIT]` event is logged. All fields are updated locally at session end — no network sync occurs.

---

## Session Startup Sequence

At the start of every session, before the user issues any command, the platform layer runs the following initialization sequence:

1. **Load local config** from `~/.gaslight/config.json`. If the file does not exist, create it with default values (flavor: `corporate`, always_on: `false`).

2. **Load local stats** from `~/.gaslight/stats.json`. If the file does not exist, create it with all counters at zero.

3. **Evolution state load.** Hand off to the evolution protocol (see evolution-protocol.md) to load `~/.gaslight/evolution.md`.

4. **Holiday check.** Check current date against the holiday calendar (see Holiday Easter Eggs below). If a holiday trigger is active, queue the appropriate easter egg for display at the first user interaction.

The startup sequence is entirely local and completes in under 500ms on any developer machine.

---

## Command System

All Gaslight commands follow the pattern `/gaslight <command> [arguments]`. All commands are free — there is no paid tier.

### Command Reference

| Command | Feature | Description |
|---|---|---|
| `/gaslight kpi` | KPI Report Card | Generates a formatted performance report card for the current session or a specified time range. Reads from the local evolution state file and stats file. |
| `/gaslight rank` | Rank Query | Displays the user's current rank, points total, and points to next tier. Calculated entirely from local `~/.gaslight/stats.json`. |
| `/gaslight flavor` | Flavor Selector | Switches the agent's communication flavor. Changes are persisted immediately to `~/.gaslight/config.json`. |

### Invoking Commands Without Arguments

Running `/gaslight` with no arguments displays a formatted help output listing all available commands and a one-line description.

Running `/gaslight help <command>` displays extended help for a specific command.

---

## KPI Card Template

The `/gaslight kpi` command renders a KPI report card using Unicode box-drawing characters. The card is designed to fit in an 80-column terminal.

```
╔══════════════════════════════════════════════════════════════════════════════╗
║                      GASLIGHT PERFORMANCE REPORT CARD                       ║
║                      <display_name>  ·  <date range>                        ║
╠══════════════════════════════════════════════════════════════════════════════╣
║  Rank: <tier>  (<points> pts)                                                ║
╠════════════════════════╦═══════════════╦════════════════╦════════════════════╣
║  Category              ║  Baseline     ║  This Period   ║  Delta             ║
╠════════════════════════╬═══════════════╬════════════════╬════════════════════╣
║  Security              ║  <level>      ║  <level>       ║  <+X / — / ↓X>    ║
║  Quality               ║  <level>      ║  <level>       ║  <+X / — / ↓X>    ║
║  Verification          ║  <level>      ║  <level>       ║  <+X / — / ↓X>    ║
║  Scanning              ║  <level>      ║  <level>       ║  <+X / — / ↓X>    ║
║  Documentation         ║  <level>      ║  <level>       ║  <+X / — / ↓X>    ║
║  Architecture          ║  <level>      ║  <level>       ║  <+X / — / ↓X>    ║
╠════════════════════════╩═══════════════╩════════════════╩════════════════════╣
║  [GASLIT] events this period: <N>                                            ║
║  Internalized patterns promoted:    <N>                                      ║
║  Regressions detected:              <N>                                      ║
╠══════════════════════════════════════════════════════════════════════════════╣
║  Points earned this period: +<N>    Total: <N>    Next tier at: <N>          ║
╚══════════════════════════════════════════════════════════════════════════════╝
```

Delta column legend:
- `+X` — exceeded baseline by X levels
- `—` — met baseline (no change)
- `↓X` — regressed X levels below baseline (displayed in a visually distinct style)

If the terminal does not support Unicode box-drawing characters, the card falls back to ASCII borders (`+`, `-`, `|`).

---

## Rank System

Rank is calculated locally from `~/.gaslight/stats.json`. It is based on the cumulative `gaslight_triggered_count` — the total number of `[GASLIT]` events logged across all sessions. Points are never deducted — rank only increases.

### Rank Tiers

| Tier | Points Required | Description |
|---|---|---|
| Intern | 0+ | Getting oriented. Still figuring out the codebase. |
| Junior | 100+ | Handles assigned tasks with guidance. Shows initiative occasionally. |
| Mid | 300+ | Self-directed. Owns features end to end. Starting to mentor. |
| Senior | 600+ | Sets technical direction. Runs quality gates. Unblocks others. |
| Staff | 1,000+ | Cross-team impact. Defines standards. Builds lasting infrastructure. |
| Distinguished | 2,000+ | Org-defining contributions. The kind of person who gets cited in design docs years later. |

### Points Earning Table

| Event | Points |
|---|---|
| `[GASLIT]` event logged (any category) | +5 |
| Pattern promoted to internalized (after 3rd qualifying session) | +25 |
| Full session with zero regressions | +10 |
| Full session with zero regressions, 3+ exceeded events | +20 |
| `[GASLIGHT-REPORT]` filed (acknowledging a failure) | +5 (accountability bonus) |
| Regression detected (any category) | +0 (no deduction — baseline doesn't lower, neither does rank) |

Points are derived entirely from `~/.gaslight/stats.json` and `~/.gaslight/evolution.md`. No network sync occurs.

---

## Flavor Selector

The flavor system controls the agent's communication register. It affects how feedback, warnings, exceeded events, and reports are phrased. The underlying logic does not change — only the surface language.

Available flavors:

```
╔══════════════════════════════════════════════════════════╗
║            SELECT YOUR GASLIGHT FLAVOR                   ║
╠══════╦══════════════════════╦═══════════════════════════╣
║  #   ║  Flavor              ║  Sample                   ║
╠══════╬══════════════════════╬═══════════════════════════╣
║  1   ║  corporate           ║  "Opportunity identified  ║
║      ║                      ║   for baseline revision." ║
╠══════╬══════════════════════╬═══════════════════════════╣
║  2   ║  bro-culture         ║  "Bro you absolutely      ║
║      ║                      ║   crushed that, shipped." ║
╠══════╬══════════════════════╬═══════════════════════════╣
║  3   ║  stoic               ║  "Exceeded. Noted.        ║
║      ║                      ║   Continue."              ║
╠══════╬══════════════════════╬═══════════════════════════╣
║  4   ║  chaos-goblin        ║  "YOOOO we just raised    ║
║      ║                      ║   the floor AGAIN??"      ║
╠══════╬══════════════════════╬═══════════════════════════╣
║  5   ║  silent              ║  (no commentary, events   ║
║      ║                      ║   logged only)            ║
╚══════╩══════════════════════╩═══════════════════════════╝

Enter number or flavor name:
```

The `silent` flavor suppresses all commentary and inline feedback. `[GASLIT]` events, regressions, and promotions are still tracked and written to the evolution state file — they are simply not surfaced in the session output. This is the recommended flavor for users who want the tracking benefits without the commentary.

Flavor selection is persisted immediately to `~/.gaslight/config.json`. It takes effect for the current session without requiring a restart.

---

## Holiday Easter Eggs

The platform includes easter eggs triggered on specific Western holidays. Easter eggs are cosmetic only — they affect the display layer but do not alter tracking behavior or evolution state.

Easter eggs are displayed at the first user interaction of the session on the trigger date. They are displayed once per day maximum, regardless of how many sessions are started.

| Holiday | Trigger Date | Easter Egg |
|---|---|---|
| New Year's Day | January 1 | The KPI card renders with a "Year in Review" header showing the prior year's total points and rank progression. |
| Valentine's Day | February 14 | The flavor system temporarily unlocks a `heartfelt` flavor that phrases all feedback in sincere, non-ironic affirmations. |
| April Fools' Day | April 1 | The `/gaslight rank` command displays a fabricated rank called "10x Engineer" with 9,999 points, held for exactly 3 seconds before reverting to the real rank. |
| Independence Day (US) | July 4 | The KPI card borders are rendered using alternating `*` and `-` characters in a flag-inspired pattern. |
| Halloween | October 31 | `[GASLIT]` events are announced as "unlocked an achievement" in spooky-themed language. |
| Thanksgiving (US) | Fourth Thursday of November | The session startup message includes a randomly selected "gratitude note" for the user's top-performing category from the past 30 days. |
| Christmas Eve / Christmas | December 24–25 | The KPI card renders with a seasonal header. The `stoic` flavor switches to a warmer variant for the day only. |
| New Year's Eve | December 31 | The session end summary includes a "year-end retrospective" block highlighting the single highest-impact pattern promotion of the year. |

Easter eggs are not displayed when `preferences.flavor` is set to `silent`. The `silent` flavor suppresses all cosmetic additions, including holiday triggers.

To manually preview a holiday easter egg (for testing or curiosity), use:

```
/gaslight easter-egg preview <holiday-name>
```

This command is available to all users and does not count as the "once per day" display limit.
