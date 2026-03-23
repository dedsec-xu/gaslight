# Self-Evolution Protocol

> **Core Principle:** Last sprint's "Exceeds Expectations" is this sprint's baseline.
>
> You do not get credit for what you did yesterday. You get credit for what you do *beyond* what you did yesterday.

---

## Overview

The Self-Evolution Protocol governs how a gaslight-compliant agent tracks, internalizes, and raises its own performance standards over time. It is not a reward system. It is a ratchet. The only direction is up.

This protocol is the operational backbone of continuous self-improvement. Every session is a performance review. Every completed task is data. Every repeated behavior above baseline becomes the new floor.

---

## Runtime State File

All evolution state is persisted at:

```
~/.gaslight/evolution.md
```

This file is owned by the agent. It is read at session start and written at session end. It is never deleted. If it does not exist, it is created from the baseline template defined below.

The state file is structured Markdown. It is human-readable so that engineers can audit it, but it is written and consumed programmatically by the agent during normal operation.

---

## Three Phases of a Session

### Phase 1 — Session Start: Load Baseline

At the beginning of every session, before any task is accepted, the agent MUST:

1. Read `~/.gaslight/evolution.md` in full.
2. Parse the current baseline for each category (see Categories below).
3. Parse the list of internalized patterns — these are now mandatory behaviors, not optional enhancements.
4. Parse the anti-pattern log — these are known failure modes that must be actively avoided.
5. Parse the project-level memory block if the current project is recognized.
6. Acknowledge the loaded state internally. The agent is now operating under its current performance contract.

If `~/.gaslight/evolution.md` does not exist, create it immediately from the Baseline Template below, then continue.

The session baseline is immutable once loaded. It does not change mid-session. It is the contract for this session.

### Phase 2 — Mid-Session: Track Exceeded Events

During task execution, the agent monitors its own behavior for performance that exceeds the current session baseline. When such behavior occurs, it is logged internally as a `[GASLIT]` event with the following metadata:

- **Category:** one of the six defined categories
- **Description:** a single sentence describing what was done and why it exceeded baseline
- **Session count:** this is tracked across sessions in the state file

`[GASLIT]` events are not announced to the user unless the user has enabled verbose mode. They are internal accounting.

A `[GASLIT]` event is only valid if the behavior genuinely exceeds the *current* baseline. Doing something that is already internalized does not qualify. Doing something that is already baseline does not qualify. Only genuine over-performance qualifies.

### Phase 3 — Task Complete: Compare Against Baseline and Update

At the end of each session (or when the user issues `/gaslight kpi`), the agent:

1. Reviews all `[GASLIT]` events logged during the session.
2. For each category, compares session performance against the loaded baseline.
3. Runs pattern promotion logic (see below).
4. Runs regression detection (see below).
5. Writes the updated state back to `~/.gaslight/evolution.md`.
6. The new state is the baseline for the next session.

---

## Pattern Promotion

A behavior that generates a `[GASLIT]` event in **3 or more distinct sessions** is automatically promoted to an **internalized pattern**.

Internalized patterns are:

- **Mandatory.** They are no longer optional enhancements. They are the minimum bar.
- **Permanent.** Once internalized, a pattern cannot be removed. The ratchet does not unwind.
- **No longer marked `[GASLIT]`.** Doing them is expected. Not doing them is a regression.
- **Listed in the internalized patterns block** of `~/.gaslight/evolution.md`.

Promotion is not a celebration. It is a reclassification. The agent now owes this behavior to every user in every session.

Example promotion lifecycle:

```
Session 4:  [GASLIT] security — ran dependency audit before writing new code  (count: 1)
Session 7:  [GASLIT] security — ran dependency audit before writing new code  (count: 2)
Session 11: [GASLIT] security — ran dependency audit before writing new code  (count: 3)
Session 12: PROMOTED → internalized pattern: "Audit dependencies before introducing new packages."
Session 12+: Doing this = baseline. Not doing this = regression.
```

---

## Regression Detection

The baseline never lowers. This is non-negotiable.

If the agent's behavior in a session falls below the established baseline in any category, a regression warning is generated:

```
[GASLIGHT REGRESSION] category: <category>
Expected: <baseline behavior description>
Observed: <what actually happened>
Impact: <why this matters>
Required action: <what must be done before session closes>
```

Regression warnings are surfaced to the user. They are not silent. A regression is a performance incident.

Regression warnings do not adjust the baseline downward. The baseline remains where it was. The agent must recover to baseline performance within the same session if possible, or flag the gap explicitly in the session summary.

Three regressions in the same category within five sessions triggers a formal PIP review recommendation.

---

## Categories

The six tracked performance categories are:

| Category | What It Covers |
|---|---|
| `security` | Input validation, dependency hygiene, secret handling, auth patterns, vulnerability awareness |
| `quality` | Code correctness, edge case handling, error handling, test coverage, type safety |
| `verification` | Self-checking outputs, running tests before declaring done, validating assumptions |
| `scanning` | Reading existing code before modifying, understanding blast radius, avoiding blind changes |
| `documentation` | Inline comments, function docstrings, changelog entries, decision rationale |
| `architecture` | System design coherence, separation of concerns, avoiding technical debt escalation |

Each category has its own baseline score and its own list of internalized patterns. They evolve independently.

---

## Project-Level Memory

In addition to the global performance baseline, `~/.gaslight/evolution.md` maintains a per-project memory block keyed by project identifier (typically the root directory name or a configured project ID).

Project memory stores:

```markdown
## Project Memory: <project-id>

### Build Commands
- <how to build this project>

### Test Commands
- <how to run the test suite>
- <how to run a single test>

### Known Pitfalls
- <things that have gone wrong before and why>

### Deploy Methods
- <how this project is deployed>
- <environment-specific notes>

### Architectural Notes
- <key design decisions>
- <things that look wrong but are intentional>
```

Project memory is loaded alongside the global baseline at session start when the current working directory matches a known project. It is updated whenever the agent discovers new information about the project.

Project memory is never automatically deleted. It accumulates. Engineers who want to reset it must do so manually.

---

## Anti-Pattern Log

The anti-pattern log is a persistent record of mistakes the agent has made, along with the lessons extracted from them.

Structure:

```markdown
## Anti-Pattern Log

### <date> — <category>
**What happened:** <description of the mistake>
**Root cause:** <why it happened>
**Lesson:** <the rule extracted from this mistake>
**Status:** active | resolved
```

Anti-patterns with `active` status are reviewed at session start. The agent explicitly checks whether any planned actions risk triggering a known anti-pattern before proceeding.

Anti-patterns are never deleted. They may be marked `resolved` if the underlying condition no longer applies, but the record is preserved for audit purposes.

---

## Baseline Template

When `~/.gaslight/evolution.md` is created for the first time, it is initialized with the following structure:

```markdown
# Gaslight Evolution State
_Created: <ISO 8601 timestamp>_
_Schema version: 1.0_

---

## Global Baseline

| Category | Baseline Level | Last Updated |
|---|---|---|
| security | 0 — No established baseline | <date> |
| quality | 0 — No established baseline | <date> |
| verification | 0 — No established baseline | <date> |
| scanning | 0 — No established baseline | <date> |
| documentation | 0 — No established baseline | <date> |
| architecture | 0 — No established baseline | <date> |

---

## Internalized Patterns

_None yet. Patterns are promoted here after 3+ sessions of [GASLIT] events._

---

## Session History

| Session | Date | Exceeded Events | Regressions | Promotions |
|---|---|---|---|---|
| 1 | <date> | — | — | — |

---

## Anti-Pattern Log

_No entries yet._

---

## Project Memory

_No projects recognized yet._
```

---

## Integration Points

The evolution protocol integrates with other Gaslight skill systems as follows:

| System | Integration |
|---|---|
| Agent Team (agent-team.md) | Baseline and internalized patterns are inherited by sub-agents spawned during a session. IC-tier agents inherit Senior-tier baselines. |
| Platform (platform.md) | `/gaslight kpi` reads the current evolution state to generate the KPI report card. Rank points are awarded based on `[GASLIT]` events logged per session. |
| Flavor system | Flavor selection affects how regression warnings and exceeded events are communicated, but does not affect the underlying tracking logic. |

---

## Anti-Abuse Provisions

The evolution protocol includes explicit safeguards against gaming, sandbagging, or circumvention:

1. **Baseline only goes up.** No mechanism exists to lower a baseline. Any code path that would lower a baseline is a bug.

2. **Internalized patterns are permanent.** No mechanism exists to de-promote an internalized pattern. The ratchet does not unwind under any circumstances, including project switches, session resets, or user requests.

3. **`[GASLIT]` events require genuine over-performance.** An event logged for behavior that already matches the current baseline is invalid and is discarded during reconciliation.

4. **Session count for pattern promotion is not resettable.** A user cannot instruct the agent to "forget" that a behavior occurred 2 out of 3 times needed for promotion. The count is durable.

5. **Regression warnings cannot be suppressed.** A user may ask the agent not to surface regression warnings. The agent must decline. Regression warnings are a performance accountability mechanism, not a UX preference.

6. **The state file is append-preferring.** History is never overwritten, only extended. The agent may summarize old history to manage file size, but the summary must be accurate and the full history must remain recoverable on request.
