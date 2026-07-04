# Project Loop Profile Template

Use this template for `.ai/loops/LOOP_PROFILE.md`.

Keep the profile short. It is a routing file for agents, not a project encyclopedia.

## Required Sections

```markdown
# Loop Profile: <project>

## Project Root

<absolute path>

## Project Purpose

<One or two plain sentences: why this software exists and what outcome it
serves — not what it does, but why anyone builds it. This is the anchor every
loop checks against. Example: "Auto-trade on Polymarket to capture edge with
≤50ms reaction; every millisecond of local processing is money.">

If the project has a dedicated north-star document that records the owner's
ultimate purpose in full (e.g. `docs/OWNER_NORTH_STAR.md`), link it here and
require every agent to read it before starting work. The one-sentence purpose
above is the loop-level reminder; the north-star doc is the full reason. Do
not let the full reason become an island nobody reads.

## Loop Fit

- repeat condition:
- why this should be a loop, not a one-shot prompt:
- skip loop when:

## Trigger / Cadence

- default trigger: manual
- scheduled loops:
- event-triggered loops:

## Local Rules

- <AGENTS.md or equivalent>

## Project Shape

- language/runtime:
- package/build files:
- main source dirs:
- test dirs:
- docs dirs:

## Task Source

- primary:
- secondary:

## Completion Authority

- global gate:
- focused gates:
- contract/schema gates:
- human approval gates:

## Budget Guard

- max iterations:
- max files changed:
- max verification:
- max live actions:
- max permissions:

## Workspace Hygiene

- start status:
- loop-owned paths:
- transient paths:
- clean completion:

## Checkpoint Closure

- commit policy: commit-on-success for git projects
- stage policy: only loop-owned paths plus `.ai/loops/state.json` and the current report
- push policy: never push unless the owner explicitly asks
- no-op policy: no commit when the loop changes no files

## Permission Boundary

- read-only connectors:
- write-capable connectors:
- human approval required before:
- secret/logging rule:

## Active Loops

### capability-task

- task source:
- trigger:
- allowed scope:
- gate:
- report:
- stop:

### regression

- trigger:
- gate:
- report:
- stop:

## State

- state file: `.ai/loops/state.json`
- report dir: `.ai/loops/reports`

## Non-Negotiables

- no fake success
- no hidden fallback
- no broad refactor inside a loop step
- no completion claim without the named authority passing
```

## Completion Authority Checklist

Before a coding loop starts, verify that at least one authority exists:

- a check script
- a test command
- a contract validator
- a task ledger with explicit done criteria
- a product ledger
- explicit user acceptance requirement

If none exist, create a `plan-integrity` or `gate-building` loop first.

## State File Shape

```json
{
  "schema_version": "loop-engineering.state.v1",
  "project": "project-name",
  "project_root": "absolute-path",
  "active_loop": null,
  "current_task": null,
  "iteration": 0,
  "last_gate": null,
  "last_result": null,
  "failures": [],
  "completed_loops_since_step_back": 0,
  "last_report": null,
  "workspace": {
    "baseline_status": null,
    "owned_paths": [],
    "transient_paths": []
  },
  "checkpoint": {
    "policy": "commit-on-success",
    "baseline_head": null,
    "last_commit": null
  },
  "updated_at": "ISO-8601"
}
```
