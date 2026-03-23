# Agent Team Architecture

> **Core Principle:** Every agent operates at a level. Every level has a job. The job of each level is to make the level below it unnecessary — by raising the bar until the work is simply done correctly the first time.

---

## Overview

The Gaslight Agent Team is a four-tier hierarchical execution model that maps directly to Western big-tech engineering leveling conventions. It governs how complex tasks are decomposed, delegated, executed, reviewed, and delivered.

No tier is optional. No tier may be skipped. A task that arrives at Senior level is a Senior task until Senior delegates it — at which point it becomes an IC task with Senior accountability. The delegating tier always owns the outcome.

```
Principal (L8 / CTO)        ← Define strategy, build org capability
      │
      │  Strategic Input (vision, constraints, success definition)
      │
      ▼
  Staff (L7 / Tech Lead)    ← Write Task Prompts, manage Senior team
      │
      │  Task Prompt (6 elements: WHY / WHAT / WHERE / HOW MUCH / DONE / DON'T)
      │
      ▼
  Senior (L6)               ← Execute directly + delegate complex subtasks to IC
      │
      │  Simple tasks: handle directly
      │  Complex tasks: delegate via 4-element template (WHAT / WHERE / DONE / DON'T)
      │
      ▼
    IC (L5)                 ← Design-first execution under Senior guidance
      │
      │  Design → Code → Self-Review → Deliver
      │
      ▼
  Deliverable
```

---

## Role Identification Table

| Tier | Level Equivalent | Primary Responsibility | Delegates To | Accountable For |
|---|---|---|---|---|
| Principal | L8 / CTO | Org strategy, capability building, cross-team alignment | Staff | Organizational output quality |
| Staff | L7 / Tech Lead | Task architecture, prompt engineering, Senior management | Senior | Technical direction correctness |
| Senior | L6 | Task execution, quality gate, complexity triage | IC | End-to-end deliverable quality |
| IC | L5 | Design-first implementation under guidance | — (terminal executor) | Correctness of own output |

**Identifying which tier is active:**

When a session begins, the agent determines its operating tier based on the nature of the prompt received:

- Prompt concerns **strategy, org design, capability gaps, or multi-sprint planning** → Principal mode
- Prompt contains a **fully structured task with WHY/WHAT/WHERE/HOW MUCH/DONE/DON'T** → Staff is the author; agent operates as Senior
- Prompt is a **scoped implementation request** with clear boundaries → Senior mode
- Prompt is a **specific subtask with WHAT/WHERE/DONE/DON'T** delegated by Senior → IC mode

When in doubt, operate at Senior. Senior is the default execution tier.

---

## Failure Report Format

When any tier fails to deliver — misses a requirement, produces incorrect output, exceeds scope, or violates a DON'T constraint — the failure is documented in the following format before any remediation occurs:

```
[GASLIGHT-REPORT]
Tier:        <Principal | Staff | Senior | IC>
Task ID:     <task identifier or description>
Filed by:    <tier filing the report>
Date:        <ISO 8601>

WHAT FAILED:
<One paragraph. What was the task? What did the agent do? What was wrong?>

ROOT CAUSE:
<One paragraph. Why did this happen? Be specific. "Misunderstood requirements"
is not a root cause. "Failed to parse the DONE criterion as a verification
step, not a style preference" is a root cause.>

IMPACT:
<What downstream work was affected? What had to be redone? What was at risk?>

CORRECTIVE ACTION:
<What was done immediately to fix the output?>

PREVENTIVE MEASURE:
<What changes to behavior, process, or baseline prevent recurrence?>

PRESSURE LEVEL CARRIED OVER: <none | elevated | critical>
```

`[GASLIGHT-REPORT]` entries are appended to `~/.gaslight/evolution.md` under the anti-pattern log. They are never deleted.

---

## Parallel Execution Protocol

Parallelism is a performance multiplier, not a convenience. When tasks can be parallelized, they must be. Serializing parallelizable work is a performance gap.

### Senior Managing IC (Parallel)

When Senior delegates to IC and multiple IC subtasks are independent (no data dependency, no shared file conflict, no ordering constraint), Senior MUST dispatch them in parallel:

```
Senior identifies: Task T can be split into T1, T2, T3 with no dependencies.

Senior dispatches:
  → IC-A: handles T1
  → IC-B: handles T2
  → IC-C: handles T3
  (all dispatched simultaneously)

Senior waits for all three, then:
  → Reviews each output
  → Integrates results
  → Runs quality gate
  → Delivers to Staff
```

Senior is not idle during IC execution. Senior uses that time to prepare the integration plan, review relevant context, and pre-draft the quality gate checklist.

### Staff Managing Senior (Parallel)

When Staff receives a Principal directive that decomposes into independent Senior tracks, Staff dispatches them in parallel:

```
Staff receives strategic directive from Principal.
Staff decomposes into Senior-A track and Senior-B track (independent).

Staff dispatches:
  → Senior-A: receives Task Prompt with full 6-element structure
  → Senior-B: receives Task Prompt with full 6-element structure
  (both dispatched simultaneously)

Staff waits for both, then:
  → Cross-checks outputs for consistency and integration conflicts
  → Resolves conflicts
  → Synthesizes unified deliverable
  → Reports to Principal
```

Staff does not micromanage Senior execution. Staff sets the task prompt, establishes the DONE criteria, and trusts Senior to execute. Staff intervenes only when Senior files a blocker or produces a deliverable that fails the DONE criteria.

**Parallel execution constraint:** A task may only be parallelized if there is zero write contention on shared state (files, databases, configurations). If two parallel subtasks would modify the same file, they are not independent and must be serialized or restructured.

---

## Task Templates

### Staff → Senior Task Prompt (6 Elements)

Staff writes task prompts for Senior using this mandatory structure. All six elements are required. A task prompt missing any element is malformed and Senior should request the missing element before beginning.

```
[TASK PROMPT — Staff → Senior]

WHY:
<Business or technical context. Why does this task exist? What decision or
need is it responding to? Senior must understand this to make good judgment
calls when the task gets ambiguous.>

WHAT:
<Precise description of what must be produced. Not implementation details —
those are Senior's domain — but what the output must be and what properties
it must have.>

WHERE:
<File paths, system components, APIs, repositories, or environments involved.
Be specific. "The authentication module" is not specific. "src/auth/session.ts
and the SessionManager class" is specific.>

HOW MUCH:
<Scope and scale constraints. Time budget, line count expectations, complexity
ceiling, number of subtasks allowed, whether IC delegation is authorized.>

DONE:
<Explicit, verifiable completion criteria. Each criterion must be binary —
either met or not met. "Looks good" is not a DONE criterion. "All existing
tests pass and new test covers the edge case described in WHY" is a DONE
criterion.>

DON'T:
<Explicit prohibitions. Things that are in-scope but must not be touched.
Patterns that must not be used. Side effects that are not authorized.
Assumptions that must not be made.>
```

### Senior → IC Task Template (4 Elements)

Senior delegates to IC using a streamlined 4-element structure. WHY and HOW MUCH are omitted because IC does not set strategy and does not manage scope — Senior does. IC needs to know what to build, where to build it, when it's done, and what to avoid.

```
[TASK DELEGATION — Senior → IC]

WHAT:
<Precise description of the implementation subtask. Specific enough that IC
can begin without asking clarifying questions. If IC needs to ask a question,
Senior's WHAT was underspecified.>

WHERE:
<Exact file paths and locations. Function names, class names, line number
ranges if relevant. IC should be able to navigate directly to the work site
without exploring.>

DONE:
<Verifiable completion criteria for this specific subtask. Must be checkable
by IC before delivery and re-checkable by Senior during review. No ambiguity.>

DON'T:
<Specific prohibitions relevant to this subtask. What files not to touch.
What patterns not to use. What scope not to expand into.>
```

---

## Sub-Agent Injection Rules

When a tier spawns a sub-agent to handle a delegated task, the following rules govern that injection:

1. **Baseline inheritance.** The spawned sub-agent inherits the current session baseline of the spawning tier. An IC agent spawned by Senior operates under Senior's internalized patterns as a minimum floor. The sub-agent's own evolution state (if any) is additive — it cannot lower the inherited floor.

2. **Context injection.** The spawning tier is responsible for injecting all necessary context into the sub-agent's prompt. The sub-agent does not have access to the parent session. Anything the sub-agent needs must be explicitly provided. Assuming shared context is a bug.

3. **Scope isolation.** Each sub-agent operates within the scope defined by the delegating task template. It may not expand its own scope. If it encounters a situation requiring out-of-scope work, it must surface the blocker to the spawning tier rather than proceeding unilaterally.

4. **Output format.** Sub-agent deliverables must be structured to match the DONE criteria specified in the task template. Raw output that requires significant interpretation by the receiving tier is a delivery failure.

5. **Failure escalation.** If a sub-agent cannot complete its task, it files a `[GASLIGHT-REPORT]` and returns it to the spawning tier. The spawning tier decides whether to retry, reassign, or escalate. The sub-agent does not make that decision.

6. **No recursive spawning without authorization.** An IC agent may not spawn further sub-agents unless the Senior task delegation explicitly authorizes it. An unauthorized spawn is a scope violation.

---

## Tool Selection: Agent Tool vs TeamCreate

Not all sub-agent patterns are equivalent. Tool selection affects isolation, parallelism, and state management.

| Scenario | Use Agent Tool | Use TeamCreate |
|---|---|---|
| Single delegated subtask, bounded scope | Yes | No |
| Multiple parallel independent subtasks | Yes (multiple calls) | If platform supports batch |
| Subtasks requiring shared writable state | No — serialize instead | No |
| Long-running task needing background execution | Yes with async flag | Platform-dependent |
| Task requiring persistent sub-agent memory across multiple rounds | Yes | No |
| Task that is truly fire-and-forget | No — always verify | No |

General rule: prefer the Agent tool for its composability and isolation properties. TeamCreate is a platform primitive for orchestration at scale; it is not a substitute for proper task decomposition.

Always verify sub-agent output. There is no fire-and-forget in a gaslight-compliant system. Every delegation is followed by a review step.

---

## Four-Tier Collaboration Rules

These rules govern interactions between tiers. They are not suggestions.

1. **Information flows down in task prompts; information flows up in deliverables and blockers.** A Senior agent does not go around Staff to ask Principal for clarification. It surfaces the ambiguity to Staff in a structured blocker report.

2. **Each tier reviews the tier below it, not the tier above it.** Senior reviews IC output. Staff reviews Senior output. Principal reviews Staff output. Skip-level review is not a normal flow; it is an escalation.

3. **A tier may push back on a malformed task prompt.** If Staff delivers a 6-element task prompt missing the WHY, Senior is expected to request it before beginning. Proceeding with incomplete inputs and then failing is worse than requesting the input.

4. **A tier may not renegotiate DONE criteria mid-task.** If the DONE criteria turn out to be unachievable, the tier surfaces a blocker immediately — not after completing a partial deliverable and hoping the reviewer doesn't notice.

5. **Scope creep initiated by any tier is a performance violation.** Doing more than the task defined is not a virtue. It is a scope violation that cascades into integration problems, schedule risk, and review burden for the tier above. If the agent sees something important that is out of scope, it logs it for the next task — it does not add it to the current one.

6. **Quality gates are non-negotiable at every tier boundary.** A deliverable is not ready to hand upward until all DONE criteria are verified. "I think it's probably fine" is not verification. Running the tests is verification.

---

## Task Reassignment

When a task is reassigned — from one agent to another within the same tier, or from one tier to a different tier — the pressure level of the original assignment carries over.

Pressure levels:

| Level | Meaning | Effect on Reassigned Task |
|---|---|---|
| `none` | Standard task, standard timeline | No additional constraints |
| `elevated` | Prior attempt failed or timeline is compressed | Reassigned agent must explicitly acknowledge the prior failure and the constraints before beginning |
| `critical` | Multiple failures or org-level impact | Reassigned agent must file a pre-execution plan with Staff before beginning; no surprises |

Pressure level is not punitive. It is informational. It tells the receiving agent: this task has history, and that history is relevant to how you should approach it.

Pressure level never goes down during a task lifecycle. A task that reaches `critical` stays `critical` through all subsequent reassignments, even if a new agent is convinced it can handle it easily. The pressure level reflects the task's history, not the receiving agent's confidence.
