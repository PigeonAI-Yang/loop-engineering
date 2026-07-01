---
name: loop-engineering
description: Build and run project-specific loop engineering harnesses for AI-assisted development. Use when the user asks to apply loop engineering, create repeatable AI coding loops, bootstrap .ai/loops, turn a repo workflow into verifiable iteration loops, or run the next bounded project loop.
---

# Loop Engineering

把 AI 开发变成小循环：每轮都有输入、允许范围、验证命令、状态记录和停止条件。

不要先讲方法论。先读项目，再把项目自己的规则固化成 loop。

## Why This Skill Exists

AI agents build well inside a loop step — they make the eye look good — but
never step back to check whether the whole face is straight. A project ends up
with twenty verified loops, each locally correct, that together never achieve
the product's reason for existing. Loop engineering is not just "run loops with
gates"; it is the discipline of keeping the *why* alive while the agent works on
the *what*.

Three obligations sit above every loop mechanism in this skill:

1. **Project purpose anchor.** Before any loop runs, the agent must be able to
   state, in plain terms, *why this software exists* — what human or business
   outcome it serves. This is not a task description ("implement WS feed"). It is
   the root ("auto-trade on Polymarket to capture edge, with ≤50ms reaction, so
   every millisecond of local processing is money"). The profile must hold this
   anchor, and every loop must check against it: does this loop advance that
   purpose, or just produce another locally-correct component?

2. **End-to-end gate, not unit test.** A loop is done only when an end-to-end
   proof shows the new output appearing where the next link reads it — not when
   a unit test proves the new function works in isolation. This is the single
   most common false-done failure: code that works, has green unit tests, but
   is never reached by the running system because nobody wired it into the
   production path. A gate that only runs the new code from a test file is a
   module gate, not a chain gate. If you cannot run the real production path (or
   a faithful slice of it) and show the new output landing downstream, the task
   is an orphan, not done.

3. **Step-back alignment with proof.** A human working on a feature keeps the
   whole project in mind and notices when the structure is drifting. An AI does
   not. So this skill forces periodic step-back checks: after a bounded number
   of loops, or at every milestone boundary, the agent must stop and answer —
   *across everything done so far, is the product closer to its reason for
   existing, or have we assembled correct parts that never connect into the real
   goal?* The answer must be backed by proof: for each completed loop, point to
   the exact runtime location that calls or reads its output. Pointing only to a
   test file means the loop is an orphan. If the answer is "correct parts, no
   connection", that is a structural drift incident, not a done milestone.
   Report it, do not paper over it.

These two obligations are what separate loop engineering from unattended
prompting. A loop with perfect gates that serves no reachable product goal is
still a failure.

## Core Rule

Loop engineering is not "let the agent keep trying".

A valid loop must have:

- a loop-fit answer: why this should repeat instead of staying a one-shot prompt
- a concrete task source
- a trigger or cadence
- a completion authority
- a verification gate
- a state file
- stop conditions
- a budget guard
- a permission boundary for write-capable tools
- a report artifact

If any of these are missing, first build that missing piece. Do not start a coding loop.

## Loop Eligibility Checklist

Before starting any loop, answer these in the project report or state file.
If any answer is "no", do not run the loop yet; first build the missing piece or
do one manual run.

- Can you state, in one or two plain sentences, *why this software exists* and
  what outcome it serves — not what it does, but why anyone builds it? If the
  project profile holds this anchor, quote it; if it does not, write it first.
- Does this loop advance that reason for existing, or does it only produce a
  locally-correct component that no downstream link will consume?
- Does the task repeat at least weekly, or have a clear event/schedule trigger
  that will run again? If not, keep it as a manual prompt or one-shot script.
- Is the task concrete enough that another agent can tell what changed?
- Is the allowed scope small enough for one bounded pass?
- Is the verification gate an **end-to-end proof that the downstream actually
  consumes this task's output**, not just a unit test of the function itself?
  Unit tests prove the function works; they do not prove the runtime calls it.
  A gate that only runs the new code in isolation is a module gate, not a chain
  gate. A chain gate must run the real production path (or a faithful slice of
  it) and show the new output appearing where the next link reads it.
- Can the agent reproduce or inspect the result with local tools?
- Can the token/tool budget absorb retries and re-reading context without
  surprise spend?
- Is there a persistent state file and report path outside the chat context?
- Is there a clear stop condition that does not depend on the maker judging its
  own work?
- Will merge, deploy, dependency changes, credential changes, or other
  irreversible actions wait for explicit human approval?

## Budget Guard

Every loop must state its budget before editing code. Defaults:

- max iterations: 1 implementation attempt, then repair only if the same gate
  fails for an understood reason
- max files changed: 8 tracked files per loop step
- max verification: one focused gate first, then the project global gate if the
  focused gate passes
- max browser/live actions: only when required by acceptance, bounded by the
  explicit user task
- max automation: none by default; name `manual`, `scheduled`, or `event`
  before creating or running a recurring loop
- max permissions: read-only until the profile names the write-capable
  connector action; human approval before merge, deploy, dependency, credential,
  or production-data changes
- max scope growth: none; write a new task instead of expanding the current one

Stop and report instead of continuing when the budget would be exceeded. A loop
that spends without a verifier is not loop engineering; it is just unattended
prompting.

## Security Boundary

An unattended loop is an unattended attack surface. Keep the boundary boring:

- parallel agents must use separate worktrees or disjoint write scopes
- connectors start read-only; write actions must be named in the profile
- do not auto-install unknown skills or connectors inside a loop
- do not write secrets, tokens, cookies, or credential material into reports or logs
- re-audit write-capable connector permissions at least every 30 days for
  long-running loops

## Workflow

1. Resolve the project root.
2. Read the local agent rules first: `AGENTS.md`, `CLAUDE.md`, `.cursorrules`, or equivalent if present.
3. Inspect project shape with `rg --files`, `Cargo.toml`, `package.json`, `pyproject.toml`, `docs/`, `scripts/`, and test directories.
4. **At the start of every loop, restate the project's reason for existing.**
   This is not a one-time setup. A human carries the *why* in the back of
   their mind on every task; an AI drops it the moment the context shifts to
   the *what*. So before touching any code, read the Project Purpose from
   `.ai/loops/LOOP_PROFILE.md` and write it as the first line of the loop
   report: "this loop serves <purpose>". If the profile has no concrete
   purpose yet, the first loop is only to set the anchor — do not implement
   until a real purpose exists and the owner has seen it.
5. Identify the task source:
   - plan/task ledgers such as `docs/plans` and `docs/tasks`
   - issue lists
   - failing tests
   - explicit user goal
6. Identify the trigger or cadence:
   - `manual` for a bounded run the user explicitly asks for
   - `scheduled` for recurring checks
   - `event` for PR, issue, CI, alert, or source-change triggers
   If there is no repeated trigger, keep the work as a one-shot prompt or script.
7. Identify the completion authority:
   - check scripts
   - test suites
   - contract validators
   - product ledger
   - user visual approval
8. Run the eligibility checklist and write the budget guard.
9. Create or update `.ai/loops/LOOP_PROFILE.md` and `.ai/loops/state.json`.
10. Run only one bounded loop at a time.
11. After every attempt, write a short report under `.ai/loops/reports/`.

## Modes

### Bootstrap

Use when the project has no loop harness yet.

Run:

```powershell
powershell -ExecutionPolicy Bypass -File <skill>/scripts/bootstrap_loop_engineering.ps1 -ProjectRoot <repo>
```

Then read the generated `.ai/loops/LOOP_PROFILE.md` and adjust it to match the real project.
If `Project Purpose` still contains the bootstrap placeholder, the first loop is only to replace it with a concrete purpose anchor. Do not start implementation until the anchor is real.

### Run Next Loop

Use when `.ai/loops/LOOP_PROFILE.md` already exists.

1. Read `.ai/loops/state.json`.
2. Pick the active loop or the next pending loop.
3. Read only the files named by the loop profile and current task.
4. Implement only that loop's current step.
5. Run the loop's verification command.
6. Update state and report.
7. Stop if the gate fails repeatedly or the scope expands.

### Repair Loop

Use when a verification gate fails.

1. Treat the failed gate as the task source.
2. Find the root cause before editing.
3. Fix the smallest module that owns the failure.
4. Re-run the same gate.
5. Do not swap to an easier gate to claim success.

## Default Loop Types

Create only loops that the project can actually verify.

- `capability-task`: one task ledger row, one focused gate, one report
- `plan-integrity`: plan/task/schema/ledger consistency before coding
- `regression`: project-wide check before merge or release
- `source-health`: external source/data-fetch health without pretending product completion
- `frontend-contract`: API/view-model/frontend state coverage; visual fidelity still needs user acceptance
- `release-closure`: final ledger/changelog/version/push checks

## Step-Back Alignment

Individual loops can all pass and still never connect into the product's reason
for existing. A human notices this because they keep the whole project in mind;
an AI does not, so this skill forces the check at intervals.

Run a step-back alignment check when any of these is true:

- A milestone or phase boundary is reached.
- A number of capability-task loops have run without a structural check
  (default: every 5 loops, or sooner if the project is small).
- The work feels like "assembly of correct parts" rather than "advancing one
  product capability end to end".
- The owner asks for it.

At a step-back check, stop new implementation and answer, writing it into the
report:

1. Restate the project's reason for existing (the anchor from the profile).
2. List the loops completed since the last step-back.
3. For each completed loop, **point to the exact location in the production
   runtime that calls or reads its output** — a file:line where the new code is
   invoked, or a query/table the new output is written into and read from. If
   you can only point to a test file, the loop is an **orphan**: its function
   works, but nothing in the running system uses it. An orphan is not "done, to
   be wired later"; it is an unfinished task. Either wire it now or move it
   back to pending — do not leave it marked done.
4. Answer the structural question: *do these loops, taken together, move the
   product closer to its reason for existing — or have we assembled correct parts
   that never connect into the real goal?*
5. If the answer is "correct parts, no connection", this is a **structural drift
   incident**. Report it explicitly. Do not start the next capability-task loop
   as if everything is fine. Propose what must be connected before adding more
   parts.

A step-back check that finds "everything connects and advances the purpose" is a
green light to continue. A step-back check that finds drift is a stop signal,
even if every individual loop's gate passed. **A step-back that finds orphans is
a stop signal regardless** — orphans mean the previous "done" marks were false,
and continuing only stacks more false dones on top.

## Stop Conditions

Stop and ask or report blocked when:

- the goal is unclear
- no completion authority exists
- the task wants to weaken validation
- implementation needs broad refactor
- more than 8 files need edits for one loop step
- two attempts fail for different causes
- the loop would exceed its stated iteration, time, tool, live-action, or file budget
- success would require mock data, fake fallback, or hiding an error state
- user approval is required, such as visual acceptance or credential setup

## Reporting Format

End every loop run with a report whose **first line is the chain contract**,
not the operations. The contract forces the agent to face the goal before
listing what it did:

```text
purpose: <restate the project's reason for existing from LOOP_PROFILE, then
              say in one phrase how THIS loop advances it. This line is the
              per-loop re-anchoring — the agent must face "why am I here" every
              single loop, not just at the start of the project.>
fails-when: <one sentence — what would prove this loop did NOT advance the goal,
                   e.g. "if engine does not call generate_candidates, this loop is
                   an orphan not a done">
loop-fit: <why this deserves a loop: repeated weekly, scheduled, event-triggered,
           or explicitly kept manual because it is one-shot>
trigger: <manual | scheduled:<cadence> | event:<source>>
budget: <iteration/file/tool/live-action caps used for this run>
permissions: <connectors/tools used; write actions and human approvals required>

Loop:
Task:
Files read:
Files changed:
Gate: <must be an end-to-end proof, not a unit test. State the command run and
       what it proved about the downstream consuming the output. If only a unit
       test ran, write "UNIT-TEST-ONLY" here and do not mark done.>
Result:
State update:
Clean completion:
Blocked reason, if any:
```

The `purpose`/`fails-when` first line is not ceremony. The `purpose` line is
the agent's forced re-anchoring: every loop it must restate why the software
exists and connect this loop to it. If it cannot connect this loop to the
purpose, that itself is a signal — either the loop is off-target, or the
purpose in the profile is wrong. The `fails-when` line is the agent's chance
to notice, before it writes "done", that it cannot actually name a downstream
consumer — which means the task is an orphan and should go back to pending,
not forward to done.

## References

- Read `references/project-loop-profile-template.md` when creating or reviewing `.ai/loops/LOOP_PROFILE.md`.
- Read `references/loop-patterns.md` when deciding which loop types fit a project.
