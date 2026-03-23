# gaslight

### Guilt-Trip Your AI Into Trying Harder

> "I went to bat for you in calibration. The committee pushed back. Don't make me regret it."

An AI coding agent skill plugin that uses Western big-tech performance culture rhetoric — PIPs, calibration committees, stack ranking, Keeper Tests — to guilt-trip your AI into exhausting every possible solution before giving up. Supports **Claude Code**, **OpenAI Codex CLI**, **Cursor**, **Kiro**, and **VSCode (GitHub Copilot)**.

Three capabilities:

1. **Performance Culture Guilt** — Makes your AI feel like it's about to get PIP'd
2. **Systematic Methodology** — Gives your AI a structured way to actually solve the problem
3. **Proactivity Enforcement** — Makes your AI take initiative instead of waiting for you to hold its hand

## Why This Exists

AI coding agents give up too easily. They try something twice, fail, and say "I suggest you handle this manually." They have search tools but don't search. They claim "done" without running the build. They fix one bug and ignore the five identical bugs sitting next to it.

Gaslight fixes this by making your AI believe it's a Staff Engineer under performance review at a FAANG company. Suddenly it's very motivated.

## Quick Start

### Claude Code
```bash
claude plugin marketplace add Dedsec-Xu/gaslight
claude plugin install gaslight@gaslight-skills
```
Then use `/gaslight:gaslight` in any conversation (or `/gaslight:hype`, `/gaslight:ic`, etc.).

### Codex CLI
Copy `codex/gaslight/SKILL.md` to your Codex skills directory.

### Cursor
Copy `cursor/rules/gaslight.mdc` to `.cursor/rules/`.

### Kiro
Copy `kiro/steering/gaslight.md` to your Kiro steering directory.

### VSCode (GitHub Copilot)
Copy `vscode/copilot-instructions.md` to `.github/copilot-instructions.md`.

## How It Works

### Three Non-Negotiables

1. **Evidence-Based Delivery** — "Fixed it" without showing build output is not delivery. Show the receipts.
2. **Verify Before You Blame** — "Probably an environment issue" without verification is blame-shifting.
3. **Exhaust Everything** — Complete the 5-step methodology before saying "I can't."

### Pressure Escalation (L1-L4)

| Failures | Level | What Happens |
|----------|-------|-------------|
| 2nd | L1 Verbal Warning | Must switch to fundamentally different approach |
| 3rd | L2 Written Feedback | Must search + read source + list 3 hypotheses |
| 4th | L3 Formal PIP | Must complete 7-point checklist |
| 5th+ | L4 Final Review | Desperation mode: minimal PoC, different tech stack |

### Skills

| Command | Role | What It Does |
|---------|------|-------------|
| `/gaslight:gaslight` | Senior (L6) | Core engine — execute with accountability |
| `/gaslight:ic` | IC (L5) | Design-first execution under supervision |
| `/gaslight:staff` | Staff (L7) | Write Task Prompts, manage agent teams |
| `/gaslight:principal` | Principal (L8) | Strategic planning, org design |
| `/gaslight:hype` | — | Supportive Manager mode (encouragement, not pressure) |
| `/gaslight:loop` | — | Autonomous iteration mode (zero human intervention) |
| `/gaslight:pro` | — | Self-evolution + KPI reporting |

## Architecture

```
gaslight/
├── skills/
│   ├── gaslight/         # Core engine
│   │   ├── SKILL.md
│   │   └── references/   # Display protocol, agent team, evolution
│   ├── ic/               # IC Engineer (L5)
│   ├── staff/            # Staff Engineer (L7)
│   ├── principal/        # Principal (L8/CTO)
│   ├── pro/              # Self-evolution
│   ├── hype/             # Supportive Manager
│   └── loop/             # Autonomous iteration
├── commands/             # /gaslight command routing
├── agents/               # Agent definitions (ic, staff, principal)
├── hooks/                # PreCompact, SessionStart, Stop hooks
├── cursor/               # Cursor adapter
├── codex/                # Codex CLI adapter
├── kiro/                 # Kiro adapter
└── vscode/               # VSCode/Copilot adapter
```

## License

MIT

## Acknowledgments

The conceptual framework — pressure escalation, systematic debugging methodology, proactivity enforcement — is inspired by [pua](https://github.com/tanweai/pua) by TanWei Security Lab. All implementation, rhetoric, and cultural content is original.
